//
//  CandidEncoder.swift
//
//
//  Created by Konstantinos Gaitanis on 18.07.24.
//

import Foundation
import BigInt
import Combine

/// `TopLevelEncoder` for encoding any `Encodable` to a `CandidValue`
/// The encoding rules are the following:
///  - `Bool`, `String`, `BigInt`, `BigUInt`, `Int<n>`,`UInt<n>`, `Float`, `Double`, `Data` are encoded to the equivalent `bool`, `text`, `nat`,`int`,`nat<n>`,`int<n>`,`float32`,`float64`,`blob`
///  - `Optionals` are encoded to `option`
///  - `Collections` are encoded to `vector`
///  - `structs` are encoded to `record`
///  - `enums` are encoded to variants. Due to limitations in the Swift Type system, we can not deduce all the cases of the enum and so the resulting variant has a single case corresponding to the current value.
///  - `CandidPrincipalProtocols` are encoded to a principal
///  - `CandidFunctionProtocols` can NOT be encoded to a function because we can not deduce the signature from the Swift type...
///  - `CandidServiceProtocols` can NOT be encoded to a service because functions can not be encoded
public class CandidEncoder: TopLevelEncoder {
    public init() { }
    
    /// Encodes `value` into a `CandidValue`
    /// - Parameter value: The value to encode
    /// - Returns: A `CandidValue` representing that value
    public func encode<T>(_ value: T) throws -> CandidValue where T: Encodable {
        let encoder = CandidValueEncoder()
        try encoder.candidEncode(value)
        return encoder.candidValue
    }
}

public enum CandidEncoderError: Error {
    case enumeratorCanNotBeEncoded
}

private class CandidValueEncoder: Encoder {
    let userInfo: [CodingUserInfoKey : Any] = [:]
    let codingPath: [CodingKey]
    private(set) var encodingValue: CandidEncodingValue!
    var candidValue: CandidValue { encodingValue.candidValue }
    
    init(_ codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
    }
    
    func candidEncode<T>(_ value: T) throws where T: Encodable {
        if let candidValue = try encodeKnownType(value) {
            encodingValue = CandidSingleEncodingValue(candidValue)
            
        } else {
            // this will be a primitive type (int, bool, ...), a struct/class or an enum
            // we go through the Swift encoding system
            try value.encode(to: self)
            // encoded candid value is now assigned to `self.encodingValue` member
            let mirror = Mirror(reflecting: value)
            if .enum == mirror.displayStyle {
                guard let record = candidValue.recordValue else {
                    throw EncodingError.invalidValue(T.self, .init(codingPath: codingPath, debugDescription: "Enums should be encoded to records"))
                }
                let variant = try convertRecordToVariant(record, using: mirror)
                encodingValue = CandidSingleEncodingValue(variant)
            }
            let withOptionals = addOptionals(to: encodingValue.candidValue, using: mirror)
            encodingValue = CandidSingleEncodingValue(withOptionals)
        }
    }
    
    private func encodeKnownType<T>(_ value: T) throws -> CandidValue? where T: Encodable {
        if let optional = value as? any CandidOptionalMarker {
            if let concreteValue = optional.value {
                let encoder = CandidValueEncoder(codingPath)
                try encoder.candidEncode(concreteValue)
                return .option(encoder.candidValue)
            } else {
                let wrappedType = candidType(optional.wrappedType)
                return .option(wrappedType)
            }
            
        } else if let candidValue = value as? CandidValue {
            return candidValue
            
        } else if let bigUInt = value as? BigUInt {
            return .natural(bigUInt)
            
        } else if let bigInt = value as? BigInt {
            return .integer(bigInt)
            
        } else if let data = value as? Data {
            return .blob(data)
            
        } else if let collection = value as? any Collection, collection.isEmpty {
            let wrappedType = candidType(collection.wrappedType)
            return .vector(wrappedType)
            
        } else if let candidFunction = value as? CandidFunction {
            return .function(candidFunction)
            
        } else if let candidPrincipal = value as? CandidPrincipal {
            return .principal(.init(candidPrincipal))
            
        } else if let candidService = value as? CandidService {
            return .service(candidService)
            
        } else if let candidFunctionProtocol = value as? CandidFunctionProtocol {
            // TODO: function arguments and results
            return .function([], [], candidFunctionProtocol.canister, candidFunctionProtocol.methodName)
            
        } else if let candidServiceProtocol = value as? CandidServiceProtocol {
            // TODO: service methods
            return .service([], candidServiceProtocol.principal)
        }
        return nil
    }
    
    private func addOptionals(to value: CandidValue, using mirror: Mirror) -> CandidValue {
        // The Swift encoding system skips the optional wrapper when a value is present, trying to directly encode the contained value
        // We add optional wrappers where needed according to the Type defined in the mirror
        switch value {
        case .record(let record):
            let newRecordItems = addOptionals(in: record.candidSortedItems, using: mirror, intMarker: "_")
            return .record(newRecordItems)
            
        case .variant(let variant):
            if let child = mirror.children.first {
                let associatedMirror = Mirror(reflecting: child.value)
                if let associatedValues = variant.value.recordValue {
                    // multiple arguments in enum case represented as record
                    let newRecordItems = addOptionals(in: associatedValues.candidSortedItems, using: associatedMirror, intMarker: ".")
                    return .variant(.init(variant.key, .record(newRecordItems)))
                    
                } else if associatedMirror.displayStyle == .tuple {
                    // case of single named argument in an enum. Swift represents this as a tuple (label, value)
                    let tupleMirror = Mirror(reflecting: associatedMirror.children.first!)
                    if tupleMirror.children.count == 2,
                       let label = tupleMirror.descendant("label") as? String,
                       let value = tupleMirror.descendant("value"),
                       let optional = value as? any CandidOptionalMarker {
                        if let _ = optional.value {
                            return .variant(.init(variant.key, .record([label: .option(variant.value)])))
                        }
                        return .variant(.init(variant.key, .record([label: .option(candidType(optional.wrappedType))])))
                    }
                    
                } else if let optional = child.value as? any CandidOptionalMarker {
                    // single value enum case
                    if let _ = optional.value {
                        return .variant(.init(variant.key, .option(variant.value)))
                    }
                    return .variant(.init(variant.key, .option(candidType(optional.wrappedType))))
                }
            }
        default: break
        }
        return value
    }
    
    private func convertRecordToVariant(_ record: CandidRecord, using mirror: Mirror) throws -> CandidValue {
        guard record.candidSortedItems.count == 1,
              let value = record.candidSortedItems.first,
              let associatedValues = value.value.recordValue else {
            throw CandidEncoderError.enumeratorCanNotBeEncoded
        }
        let variantValueKey = value.key
        if associatedValues.candidSortedItems.isEmpty {
            return .variant(CandidKeyedValue(variantValueKey))
            
        } else if associatedValues.candidSortedItems.count == 1,
               let associatedValue = associatedValues.candidSortedItems.first,
                  associatedValue.key.stringValue == "_0" {
            return .variant(CandidKeyedValue(variantValueKey, associatedValue.value))
            
        } else {
            let variantValues = try associatedValues.candidSortedItems.map {
                return CandidKeyedValue(try $0.key.toVariantKey(), $0.value)
            }
            return .variant(CandidKeyedValue(value.key, .record(variantValues)))
        }
    }
    
    private func addOptionals(in keyedValues: [CandidKeyedValue], using mirror: Mirror, intMarker: String) -> [CandidKeyedValue] {
        var newRecordItems = keyedValues
        for child in mirror.children {
            if let existing = keyedValues.first(where: {
                $0.key.stringValue == child.label ||
                "\(intMarker)\($0.key.intValue)" == child.label ||
                $0.key.intValue == child.label.map { CandidKey.candidHash($0) }
            }) {
                if child.value is any CandidOptionalMarker {
                    newRecordItems.replace(existing.key, with: .option(existing.value))
                }
            } else {
                if let optional = child.value as? any CandidOptionalMarker,
                   let label = child.label {
                    newRecordItems.append(.init(label, .option(candidType(optional.wrappedType))))
                }
            }
        }
        return newRecordItems
    }
        
    private func candidType(_ type: Any.Type) -> CandidType {
        switch type {
        case is Bool.Type: return .bool
        case is String.Type: return .text
        case is Data.Type: return .blob
        case is UInt8.Type: return .natural8
        case is UInt16.Type: return .natural16
        case is UInt32.Type: return .natural32
        case is UInt64.Type: return .natural64
        case is UInt.Type: return .natural64
        case is BigUInt.Type: return .natural
        case is Int8.Type: return .integer8
        case is Int16.Type: return .integer16
        case is Int32.Type: return .integer32
        case is Int64.Type: return .integer64
        case is Int.Type: return .integer64
        case is BigInt.Type: return .integer
        case is Float.Type: return .float32
        case is Double.Type: return .float64
        case is any CandidOptionalMarker.Type:
            let optional = type as! any CandidOptionalMarker.Type
            return .option(candidType(optional.self.wrappedType))
        default:
            // TODO: can we detect the structure of an Encodable Type using CodingKeys?
            return .empty
        }
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = CandidKeyedEncodingContainer<Key>(codingPath)
        encodingValue = container.encodingValue
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = CandidUnkeyedEncodingContainer(codingPath)
        encodingValue = container.encodingValue
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = CandidSingleValueEncodingContainer(codingPath)
        encodingValue = container.encodingValue
        return container
    }
}

// MARK: EncodingValue
private protocol CandidEncodingValue: AnyObject {
    var candidValue: CandidValue! { get }
}

private class CandidSingleEncodingValue: CandidEncodingValue {
    private(set) var candidValue: CandidValue!
    
    func set(_ value: CandidValue) { candidValue = value }
    func set(_ value: Bool) { candidValue = .bool(value) }
    func set(_ value: String) { candidValue = .text(value) }
    func set(_ value: Float) { candidValue = .float32(value) }
    func set(_ value: Double) { candidValue = .float64(value) }
    func set(_ value: Int) { candidValue = .integer64(Int64(value)) }
    func set(_ value: Int8) { candidValue = .integer8(value) }
    func set(_ value: Int16) { candidValue = .integer16(value) }
    func set(_ value: Int32) { candidValue = .integer32(value) }
    func set(_ value: Int64) { candidValue = .integer64(value) }
    func set(_ value: UInt) { candidValue = .natural64(UInt64(value)) }
    func set(_ value: UInt8) { candidValue = .natural8(value) }
    func set(_ value: UInt16) { candidValue = .natural16(value) }
    func set(_ value: UInt32) { candidValue = .natural32(value) }
    func set(_ value: UInt64) { candidValue = .natural64(value) }
    
    init() {}
    init(_ value: CandidValue) { candidValue = value }
    init(_ value: Bool) { candidValue = .bool(value) }
    init(_ value: String) { candidValue = .text(value) }
    init(_ value: Float) { candidValue = .float32(value) }
    init(_ value: Double) { candidValue = .float64(value) }
    init(_ value: Int) { candidValue = .integer64(Int64(value)) }
    init(_ value: Int8) { candidValue = .integer8(value) }
    init(_ value: Int16) { candidValue = .integer16(value) }
    init(_ value: Int32) { candidValue = .integer32(value) }
    init(_ value: Int64) { candidValue = .integer64(value) }
    init(_ value: UInt) { candidValue = .natural64(UInt64(value)) }
    init(_ value: UInt8) { candidValue = .natural8(value) }
    init(_ value: UInt16) { candidValue = .natural16(value) }
    init(_ value: UInt32) { candidValue = .natural32(value) }
    init(_ value: UInt64) { candidValue = .natural64(value) }
}

private class CandidUnkeyedEncodingValue: CandidEncodingValue {
    var candidValue: CandidValue! { try! .vector(items.map { $0.candidValue } ) }
    private var items: [CandidEncodingValue] = []
    var count: Int { items.count }
    func append(_ value: CandidEncodingValue) { items.append(value) }
}

private class CandidKeyedEncodingValue<Key>: CandidEncodingValue where Key: CodingKey {
    var candidValue: CandidValue! { .record(items.map { CandidKeyedValue($0.key, $0.value.candidValue) }) }
    private var items: [CandidKey: CandidEncodingValue] = [:]
    func set(_ value: CandidEncodingValue, for key: Key) { items[candidKey(for: key)] = value }
    
    private func candidKey(for key: Key) -> CandidKey {
        if let int = key.intValue, int != CandidKey.candidHash(key.stringValue) {
            return CandidKey(int)
        }
        return CandidKey(key.stringValue)
    }
}

// MARK: EncodingContainers
private protocol CandidEncodingContainer {
    associatedtype EncodingValue: CandidEncodingValue
    var codingPath: [CodingKey] { get }
    var encodingValue: EncodingValue { get }
}

private class CandidSingleValueEncodingContainer: SingleValueEncodingContainer, CandidEncodingContainer {
    let codingPath: [CodingKey]
    let encodingValue = CandidSingleEncodingValue()
    
    init(_ codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let valueEncoder = CandidValueEncoder(codingPath)
        try valueEncoder.candidEncode(value)
        encodingValue.set(valueEncoder.candidValue)
    }
}

private class CandidUnkeyedEncodingContainer: UnkeyedEncodingContainer, CandidEncodingContainer {
    var codingPath: [CodingKey] { rootCodingPath + [IntCodingKey(intValue: count)] }
    let encodingValue = CandidUnkeyedEncodingValue()
    private let rootCodingPath: [CodingKey]
    var count: Int { encodingValue.count }
    
    init(_ codingPath: [CodingKey]) {
        rootCodingPath = codingPath
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let nestedContainer = CandidKeyedEncodingContainer<NestedKey>(codingPath)
        encodingValue.append(nestedContainer.encodingValue)
        return KeyedEncodingContainer(nestedContainer)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let nestedContainer = CandidUnkeyedEncodingContainer(codingPath)
        encodingValue.append(nestedContainer.encodingValue)
        return nestedContainer
    }
    
    func superEncoder() -> Encoder { fatalError("not supported") }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let valueEncoder = CandidValueEncoder(codingPath)
        try valueEncoder.candidEncode(value)
        encodingValue.append(valueEncoder.encodingValue)
    }
}

private class CandidKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol, CandidEncodingContainer {
    typealias EncodingValue = CandidKeyedEncodingValue<Key>
    let encodingValue = CandidKeyedEncodingValue<Key>()
    let codingPath: [CodingKey]
    
    init(_ codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let valueEncoder = CandidValueEncoder(codingPath + [key])
        try valueEncoder.candidEncode(value)
        encodingValue.set(valueEncoder.encodingValue, for: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let nestedContainer = CandidKeyedEncodingContainer<NestedKey>(codingPath)
        encodingValue.set(nestedContainer.encodingValue, for: key)
        return KeyedEncodingContainer(nestedContainer)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let nestedContainer = CandidUnkeyedEncodingContainer(codingPath)
        encodingValue.set(nestedContainer.encodingValue, for: key)
        return nestedContainer
    }
    
    func superEncoder() -> Encoder { fatalError("not supported") }
    func superEncoder(forKey key: Key) -> Encoder { fatalError("not supported") }
}

// MARK: Encoding primitives
extension CandidSingleValueEncodingContainer {
    func encodeNil() throws { fatalError() }
    func encode(_ value: Bool) throws { encodingValue.set(value) }
    func encode(_ value: String) throws { encodingValue.set(value) }
    func encode(_ value: Float) throws { encodingValue.set(value) }
    func encode(_ value: Double) throws { encodingValue.set(value) }
    func encode(_ value: Int) throws { encodingValue.set(value) }
    func encode(_ value: Int8) throws { encodingValue.set(value) }
    func encode(_ value: Int16) throws { encodingValue.set(value) }
    func encode(_ value: Int32) throws { encodingValue.set(value) }
    func encode(_ value: Int64) throws { encodingValue.set(value) }
    func encode(_ value: UInt) throws { encodingValue.set(value) }
    func encode(_ value: UInt8) throws { encodingValue.set(value) }
    func encode(_ value: UInt16) throws { encodingValue.set(value) }
    func encode(_ value: UInt32) throws { encodingValue.set(value) }
    func encode(_ value: UInt64) throws { encodingValue.set(value) }
}

extension CandidUnkeyedEncodingContainer {
    func encodeNil() throws { fatalError() }
    func encode(_ value: Bool) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: String) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: Float) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: Double) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: Int) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: Int8) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: Int16) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: Int32) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: Int64) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: UInt) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: UInt8) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: UInt16) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: UInt32) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
    func encode(_ value: UInt64) throws { encodingValue.append(CandidSingleEncodingValue(value)) }
}

extension CandidKeyedEncodingContainer {
    func encodeNil(forKey: Key) throws { fatalError() }
    func encode(_ value: Bool, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: String, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: Float, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: Double, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: Int, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: Int8, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: Int16, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: Int32, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: Int64, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: UInt, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: UInt8, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: UInt16, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: UInt32, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
    func encode(_ value: UInt64, for key: Key) throws { encodingValue.set(CandidSingleEncodingValue(value), for: key) }
}

// MARK: Wrapped Types
private protocol CandidOptionalMarker {
    associatedtype Wrapped: Encodable
    static var wrappedType: Wrapped.Type { get }
    var value: Wrapped? { get }
    var wrappedType: Wrapped.Type { get }
}

extension Optional: CandidOptionalMarker where Wrapped: Encodable {
    var value: Wrapped? { self }
    var wrappedType: Wrapped.Type { Wrapped.self }
    static var wrappedType: Wrapped.Type { Wrapped.self }
}

private extension Collection {
    var wrappedType: Element.Type { Element.self }
}

private extension CandidKey {
    func toVariantKey() throws -> CandidKey {
        let regex = /_(?<number>\d+)/
        guard let stringKey = stringValue,
              let match = stringKey.wholeMatch(of: regex),
              let intKey = Int(match.number) else {
            return self
        }
        return CandidKey(intKey)
    }
}

private extension Array<CandidKeyedValue> {
    mutating func replace(_ key: CandidKey, with newValue: CandidValue) {
        replace(key.intValue, with: newValue)
    }
    
    mutating func replace(_ stringKey: String, with newValue: CandidValue) {
        replace(CandidKey.candidHash(stringKey), with: newValue)
    }
    
    mutating func replace(_ intKey: Int, with newValue: CandidValue) {
        guard let index = firstIndex(where: { $0.key.intValue == intKey }) else {
            return
        }
        let key = self[index].key
        remove(at: index)
        insert(.init(key, newValue), at: index)
    }
}

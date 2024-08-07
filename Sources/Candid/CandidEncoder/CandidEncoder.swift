//
//  CandidEncoder.swift
//
//
//  Created by Konstantinos Gaitanis on 18.07.24.
//

import Foundation
import BigInt
import Combine

public class CandidEncoder: TopLevelEncoder {
    public init() { }
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
    private (set) var encodingValue: CandidEncodingValue!
    var candidValue: CandidValue { encodingValue.candidValue }
    
    init(_ codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
    }
    
    func candidEncode<T>(_ value: T) throws where T: Encodable {
        if let bigUInt = value as? BigUInt {
            encodingValue = CandidSingleEncodingValue(bigUInt)
            
        } else if let bigInt = value as? BigInt {
            encodingValue = CandidSingleEncodingValue(bigInt)
            
        } else if let data = value as? Data {
            encodingValue = CandidSingleEncodingValue(data)
            
        } else if let optional = value as? any CandidOptionalMarker {
            if let concreteValue = optional.value {
                let encoder = CandidValueEncoder(codingPath)
                try encoder.candidEncode(concreteValue)
                encodingValue = CandidSingleEncodingValue(.option(encoder.candidValue))
            } else {
                let wrappedType = candidType(optional.wrappedType)
                encodingValue = CandidSingleEncodingValue(.option(wrappedType))
            }
            
        } else if let collection = value as? any Collection, collection.isEmpty {
            let wrappedType = candidType(collection.wrappedType)
            encodingValue = CandidSingleEncodingValue(.vector(wrappedType))
            
        } else if let candidFunction = value as? CandidFunction {
            encodingValue = CandidSingleEncodingValue(.function(candidFunction))
            
        } else if let candidPrincipal = value as? any CandidPrincipalProtocol {
            encodingValue = CandidSingleEncodingValue(.principal(.init(candidPrincipal)))
            
        } else if let candidService = value as? CandidService {
            encodingValue = CandidSingleEncodingValue(.service(candidService))
            
        } else {
            try value.encode(to: self)
            
            let mirror = Mirror(reflecting: value)
            if .enum == mirror.displayStyle {
                // TODO: CaseIterable can define all the variant cases
                guard let record = candidValue.recordValue else {
                    throw EncodingError.invalidValue(T.self, .init(codingPath: codingPath, debugDescription: "Enums should be encoded to records"))
                }
                let variant = try convertRecordToVariant(record)
                encodingValue = CandidSingleEncodingValue(variant)
            }
        }
    }
    
    private func convertRecordToVariant(_ record: CandidRecord) throws -> CandidValue {
        guard record.candidSortedItems.count == 1,
              let value = record.candidSortedItems.first,
              let associatedValues = value.value.recordValue else {
            throw CandidEncoderError.enumeratorCanNotBeEncoded
        }
        let variantValueKey = value.key
        if associatedValues.candidSortedItems.isEmpty {
            return .variant(CandidKeyedValue(variantValueKey))
        } else if associatedValues.candidSortedItems.count == 1,
               let associatedValue = associatedValues.candidSortedItems.first {
            return .variant(CandidKeyedValue(variantValueKey, associatedValue.value))
        } else {
            let variantValues = try associatedValues.candidSortedItems.map {
                return CandidKeyedValue(try $0.key.toVariantKey(), $0.value)
            }
            return .variant(CandidKeyedValue(value.key, .record(variantValues)))
        }
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
            // TODO: How can we unwrap the contained type?
            // eg. Bool??.none can not be identified
            return .option(.empty)
        default:
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
    private (set) var candidValue: CandidValue!
    func set(_ value: CandidValue) { candidValue = value }
    func set(_ value: Bool) { candidValue = .bool(value) }
    func set(_ value: String) { candidValue = .text(value) }
    func set(_ value: Float) { candidValue = .float32(value) }
    func set(_ value: Double) { candidValue = .float64(value) }
    func set(_ value: BigInt) { candidValue = .integer(value) }
    func set(_ value: Int) { candidValue = .integer64(Int64(value)) }
    func set(_ value: Int8) { candidValue = .integer8(value) }
    func set(_ value: Int16) { candidValue = .integer16(value) }
    func set(_ value: Int32) { candidValue = .integer32(value) }
    func set(_ value: Int64) { candidValue = .integer64(value) }
    func set(_ value: BigUInt) { candidValue = .natural(value) }
    func set(_ value: UInt) { candidValue = .natural64(UInt64(value)) }
    func set(_ value: UInt8) { candidValue = .natural8(value) }
    func set(_ value: UInt16) { candidValue = .natural16(value) }
    func set(_ value: UInt32) { candidValue = .natural32(value) }
    func set(_ value: UInt64) { candidValue = .natural64(value) }
    func set(_ value: Data) { candidValue = .blob(value) }
    
    init() {}
    init(_ value: CandidValue) { candidValue = value }
    init(_ value: Bool) { candidValue = .bool(value) }
    init(_ value: String) { candidValue = .text(value) }
    init(_ value: Float) { candidValue = .float32(value) }
    init(_ value: Double) { candidValue = .float64(value) }
    init(_ value: BigInt) { candidValue = .integer(value) }
    init(_ value: Int) { candidValue = .integer64(Int64(value)) }
    init(_ value: Int8) { candidValue = .integer8(value) }
    init(_ value: Int16) { candidValue = .integer16(value) }
    init(_ value: Int32) { candidValue = .integer32(value) }
    init(_ value: Int64) { candidValue = .integer64(value) }
    init(_ value: BigUInt) { candidValue = .natural(value) }
    init(_ value: UInt) { candidValue = .natural64(UInt64(value)) }
    init(_ value: UInt8) { candidValue = .natural8(value) }
    init(_ value: UInt16) { candidValue = .natural16(value) }
    init(_ value: UInt32) { candidValue = .natural32(value) }
    init(_ value: UInt64) { candidValue = .natural64(value) }
    init(_ value: Data) { candidValue = .blob(value) }
}

private class CandidUnkeyedEncodingValue: CandidEncodingValue {
    var candidValue: CandidValue! { try! .vector(items.map { $0.candidValue } ) }
    private var items: [CandidEncodingValue] = []
    var count: Int { items.count }
    func append(_ value: CandidEncodingValue) { items.append(value) }
    func append(_ value: CandidValue) { append(CandidSingleEncodingValue(value)) }
}

private class CandidKeyedEncodingValue<Key>: CandidEncodingValue where Key: CodingKey {
    var candidValue: CandidValue! { .record(items.map { CandidKeyedValue($0.key, $0.value.candidValue) }) }
    private var items: [CandidKey: CandidEncodingValue] = [:]
    func set(_ value: CandidEncodingValue, for key: Key) { items[candidKey(for: key)] = value }
    func set(_ value: CandidValue, for key: Key) { set(CandidSingleEncodingValue(value), for: key) }
    
    private func candidKey(for key: Key) -> CandidKey {
        if let int = key.intValue {
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
    var value: Wrapped? { get }
    var wrappedType: Wrapped.Type { get }
}

extension Optional: CandidOptionalMarker where Wrapped: Encodable {
    var value: Wrapped? { self }
    var wrappedType: Wrapped.Type { Wrapped.self }
}

private extension Collection {
    var wrappedType: Element.Type { Element.self }
}

private extension CandidKey {
    func toVariantKey() throws -> CandidKey {
        guard let stringKey = stringValue,
            let numberString = try Self.unnamedEnumRegex.wholeMatch(in: stringKey)?["number"]?.substring,
              let intKey = Int(numberString) else {
            return self
        }
        return CandidKey(intKey)
    }
    
    static let unnamedEnumRegex = try! Regex(#"_(?'number'\d+)"#)
}

//
//  CandidDecoder.swift
//
//
//  Created by Konstantinos Gaitanis on 18.07.24.
//

import Foundation
import BigInt
import Combine


/// `TopLevelDecoder` for decoding a `CandidValue` into a `Decodable`
/// The decoding rules are the following:
///  - bool -> Bool
///  - text -> String (utf8)
///  - int -> BigInt
///  - nat -> BigUInt
///  - int<n> -> Int<n>
///  - nat<n> -> UInt<n>
///  - blob -> Data
///  - vec <type> -> [<swift_type>]
///  - opt <type> -> <swift_type>?
///  - record -> struct with same keys. Keys with only a number `n` are converted to "_n"
///  - variant -> enum
///  - principal -> `CandidPrincipalProtocol`
///  - function -> `CandidFunctionProtocol`
///  - service -> `CandidServiceProtocol`
///  - null, empty, reservec -> nil
public class CandidDecoder: TopLevelDecoder {
    public init() {}
    
    /// Decodes the given `CandidValue` into the given `Decodable` type
    /// - Parameter value: The `CandidValue` to decode
    /// - Returns: The input value encoded into type `T`
    public func decode<T>(_ value: CandidValue) throws -> T where T: Decodable {
        return try decode(T.self, from: value)
    }
    
    /// Decodes the given `CandidValue` into the given `Decodable` type
    /// - Parameters:
    ///   - type: The type into which the value will be decoded
    ///   - value: The `CandidValue` to decode
    /// - Returns: The input value encoded into type `T`
    public func decode<T>(_ type: T.Type, from value: CandidValue) throws -> T where T: Decodable {
        let decoder = CandidValueDecoder(value)
        let decoded: T = try decoder.candidDecode()
        return decoded
    }
}

public enum CandidDecoderError: Error {
    case incompatibleTypes(input: CandidType, output: String)
    case invalidContainer
    case invalidIntegerConversion
}

private class CandidValueDecoder: Decoder {
    let codingPath: [any CodingKey]
    let input: CandidValue
    let userInfo: [CodingUserInfoKey : Any] = [:]
    
    init(_ input: CandidValue, _ codingPath: [any CodingKey] = []) {
        self.input = input
        self.codingPath = codingPath
    }
    
    func candidDecode<T>() throws -> T where T: Decodable {
        if T.self is BigUInt.Type {
            let bigUInt = try input.natural(codingPath)
            return bigUInt as! T
            
        } else if T.self is BigInt.Type {
            let bigInt = try input.integer(codingPath)
            return bigInt as! T
            
        } else if T.self is CandidValue.Type {
            return input as! T
            
        } else if T.self is CandidPrincipal.Type {
            let principal = try input.principal(codingPath)
            let principalProtocol = (T.self as! CandidPrincipal.Type).init(principal.bytes)
            return principalProtocol as! T
            
        } else if T.self is CandidFunctionProtocol.Type {
            let function = try input.function(codingPath)
            guard let method = function.method else {
                throw EncodingError.invalidValue(function, .init(codingPath: codingPath, debugDescription: "No method defined in CandidFunction"))
            }
            let functionProtocol = (T.self as! CandidFunctionProtocol.Type).init(method.principal, method.name)
            return functionProtocol as! T
            
        } else if T.self is CandidServiceProtocol.Type {
            let service = try input.service(codingPath)
            guard let principal = service.principal else {
                throw EncodingError.invalidValue(service, .init(codingPath: codingPath, debugDescription: "No principal defined in CandidService"))
            }
            let serviceProtocol = (T.self as! CandidServiceProtocol.Type).init(principal)
            return serviceProtocol as! T
        }
        return try T.init(from: self)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        return KeyedDecodingContainer(try CandidKeyedDecodingContainer(input, codingPath))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try CandidUnkeyedDecodingContainer(input, codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return CandidSingleValueDecodingContainer(input, codingPath)
    }
}

// MARK: DecodingContainers
private class CandidSingleValueDecodingContainer: SingleValueDecodingContainer {
    let codingPath: [CodingKey]
    let input: CandidValue
    
    init(_ input: CandidValue, _ codingPath: [CodingKey]) {
        self.input = input
        self.codingPath = codingPath
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let childValue = input.optionValue?.value ?? input
        let decoder = CandidValueDecoder(childValue, codingPath + [IntCodingKey(intValue: 0)])
        return try decoder.candidDecode()
    }
}

private class CandidUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] { rootCodingPath + [IntCodingKey(intValue: currentIndex)] }
    var count: Int? { inputVector.count }
    var isAtEnd: Bool { currentIndex == count }
    private let inputVector: [CandidValue]
    private (set) var currentIndex: Int = 0
    private let rootCodingPath: [CodingKey]
    
    init(_ input: CandidValue, _ codingPath: [CodingKey]) throws {
        self.rootCodingPath = codingPath
        if let data = input.blobValue {
            self.inputVector = data.map { CandidValue.natural8($0) }
        } else if let vector = input.vectorValue {
            self.inputVector = vector.values
        } else {
            throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "not a vector"))
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let childValue = try getNextValue()
        return KeyedDecodingContainer(try CandidKeyedDecodingContainer<NestedKey>(childValue, codingPath))
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let childValue = try getNextValue()
        return try CandidUnkeyedDecodingContainer(childValue, codingPath)
    }
    
    func superDecoder() throws -> Decoder { fatalError("superDecoder not supported") }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let childValue = try getNextValue()
        let decoder = CandidValueDecoder(childValue, codingPath)
        return try decoder.candidDecode()
    }
    
    func getNextValue() throws -> CandidValue {
        guard inputVector.count > currentIndex else {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "out of bounds. Have \(inputVector.count) but trying to parse more")
        }
        let childValue = inputVector[currentIndex]
        currentIndex += 1
        return childValue
    }
}

private class CandidKeyedDecodingContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
    let codingPath: [CodingKey]
    var allKeys: [Key] { 
        // only used for enums
        values.compactMap {
            $0.key.stringValue.map { Key(stringValue: $0) } ?? Key(intValue: $0.key.intValue)
        }
    }
    private let keys: [CandidKey]
    private let values: [CandidKey: CandidValue]
    
    init(_ input: CandidValue, _ codingPath: [CodingKey]) throws {
        if let record = input.recordValue {
            keys = record.candidSortedItems.map { $0.key }
            // In case of an optional value, the Swift decoding system will first call `contains(_)`.
            // If that returns false, it will automatically encode a nil
            // If that return true, it will skip the optional wrapper and directly decode the value
            // for that reason, we remove all optional wrappers when a value is present and answer correctly to the `contains(_)` call.
            values = Dictionary(uniqueKeysWithValues: record.candidSortedItems.map { ($0.key, $0.value.withRemovedOptionals) } )
            
        } else if let variant = input.variantValue {
            keys = variant.candidTypes.map { $0.key }
            values = Dictionary(uniqueKeysWithValues: [(variant.key, variant.value.withRemovedOptionals)] )
            
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "not a keyed container"))
        }
        self.codingPath = codingPath
    }
    
    func contains(_ key: Key) -> Bool {
        // used for optional values
        let key = candidKey(key)
        guard let value = values[key] else {
            return false
        }
        return value.hasValue
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        guard let value = values[candidKey(key)] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "key not found"))
        }
        let decoder = CandidValueDecoder(value, codingPath + [key])
        return try decoder.candidDecode()
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        // this is the case of enums with associatedValues
        guard let value = values[candidKey(key)] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "key not found"))
        }
        let associatedCandidValue: CandidValue
        if let record = value.recordValue {
            let associatedValueItems = record.candidSortedItems.map {
                CandidKeyedValue($0.key.toEnumKey(), $0.value)
            }
            if associatedValueItems.contains(where: {
                $0.key.stringValue.map { NestedKey(stringValue: $0) } ?? NestedKey(intValue: $0.key.intValue) != nil
            }) {
                // at least one associatedValue can be mapped to NestedKey, this is the case an enum with at least one associated value
                associatedCandidValue = .record(associatedValueItems)
            } else {
                // this is the case of an enum containing a single unnamed value of type record
                // we handle this like the case of a single value.
                associatedCandidValue = CandidValue.record(["_0": value])
            }
            
        } else {
            associatedCandidValue = CandidValue.record(["_0": value])
        }
        return KeyedDecodingContainer(try CandidKeyedDecodingContainer<NestedKey>(associatedCandidValue, codingPath + [key]))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        guard let value = values[candidKey(key)] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "key not found"))
        }
        return try CandidUnkeyedDecodingContainer(value, codingPath + [key])
    }
    
    func superDecoder() throws -> Decoder { fatalError("superDecoder not supported") }
    func superDecoder(forKey key: Key) throws -> Decoder { fatalError("superDecoder not supported") }
    
    private func candidKey(_ key: Key) -> CandidKey {
        key.intValue.map { CandidKey($0) } ?? CandidKey(key.stringValue)
    }
    
    private func value(_ key: Key) throws -> CandidValue {
        guard let value = values[candidKey(key)] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "key not found"))
        }
        return value
    }
}

// MARK: Primitive Decoding
extension CandidSingleValueDecodingContainer {
    func decodeNil() -> Bool { input.isNil }
    func decode(_ type: Bool.Type) throws -> Bool { try input.bool(codingPath) }
    func decode(_ type: String.Type) throws -> String { try input.text(codingPath) }
    func decode(_ type: Double.Type) throws -> Double { try input.float64(codingPath) }
    func decode(_ type: Float.Type) throws -> Float { try input.float32(codingPath) }
    func decode(_ type: Int.Type) throws -> Int { Int(try input.integer64(codingPath)) }
    func decode(_ type: Int8.Type) throws -> Int8 { try input.integer8(codingPath) }
    func decode(_ type: Int16.Type) throws -> Int16 { try input.integer16(codingPath) }
    func decode(_ type: Int32.Type) throws -> Int32 { try input.integer32(codingPath) }
    func decode(_ type: Int64.Type) throws -> Int64 { try input.integer64(codingPath) }
    func decode(_ type: UInt.Type) throws -> UInt { UInt(try input.natural64(codingPath)) }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try input.natural8(codingPath) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try input.natural16(codingPath) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try input.natural32(codingPath) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try input.natural64(codingPath) }
}

extension CandidUnkeyedDecodingContainer {
    func decodeNil() throws -> Bool { try getNextValue().isNil }
    func decode(_ type: Bool.Type) throws -> Bool { try getNextValue().bool(codingPath) }
    func decode(_ type: String.Type) throws -> String { try getNextValue().text(codingPath) }
    func decode(_ type: Double.Type) throws -> Double { try getNextValue().float64(codingPath) }
    func decode(_ type: Float.Type) throws -> Float { try getNextValue().float32(codingPath) }
    func decode(_ type: Int.Type) throws -> Int { Int(try getNextValue().integer64(codingPath)) }
    func decode(_ type: Int8.Type) throws -> Int8 { try getNextValue().integer8(codingPath) }
    func decode(_ type: Int16.Type) throws -> Int16 { try getNextValue().integer16(codingPath) }
    func decode(_ type: Int32.Type) throws -> Int32 { try getNextValue().integer32(codingPath) }
    func decode(_ type: Int64.Type) throws -> Int64 { try getNextValue().integer64(codingPath) }
    func decode(_ type: UInt.Type) throws -> UInt { UInt(try getNextValue().natural(codingPath)) }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try getNextValue().natural8(codingPath) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try getNextValue().natural16(codingPath) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try getNextValue().natural32(codingPath) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try getNextValue().natural64(codingPath) }
}

extension CandidKeyedDecodingContainer {
    func decodeNil(forKey key: Key) throws -> Bool { try value(key).isNil }
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { try value(key).bool(codingPath + [key]) }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { try value(key).text(codingPath + [key]) }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { try value(key).float64(codingPath + [key]) }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float { try value(key).float32(codingPath + [key]) }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int { Int(try value(key).integer64(codingPath + [key])) }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { try value(key).integer8(codingPath + [key]) }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { try value(key).integer16(codingPath + [key]) }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { try value(key).integer32(codingPath + [key]) }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { try value(key).integer64(codingPath + [key]) }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { UInt(try value(key).natural64(codingPath + [key])) }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { try value(key).natural8(codingPath + [key]) }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { try value(key).natural16(codingPath + [key]) }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { try value(key).natural32(codingPath + [key]) }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { try value(key).natural64(codingPath + [key]) }
}

private extension CandidValue {
    private func typeMismatch<T>(_ codingPath: [CodingKey], _ type: T.Type) -> DecodingError {
        return DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not a \(type)"))
    }
    
    func bool(_ codingPath: [CodingKey]) throws -> Bool {
        guard case .bool(let bool) = self else { throw typeMismatch(codingPath, Bool.self) }
        return bool
    }
    
    func natural(_ codingPath: [CodingKey]) throws -> BigUInt {
        guard case .natural(let bigUInt) = self else {   throw typeMismatch(codingPath, BigUInt.self) }
        return bigUInt
    }
    
    func natural8(_ codingPath: [CodingKey]) throws -> UInt8 {
        guard case .natural8(let uInt8) = self else {   throw typeMismatch(codingPath, UInt8.self) }
        return uInt8
    }
    
    func natural16(_ codingPath: [CodingKey]) throws -> UInt16 {
        guard case .natural16(let uInt16) = self else {   throw typeMismatch(codingPath, UInt16.self) }
        return uInt16
    }
    
    func natural32(_ codingPath: [CodingKey]) throws -> UInt32 {
        guard case .natural32(let uInt32) = self else {   throw typeMismatch(codingPath, UInt32.self) }
        return uInt32
    }
    
    func natural64(_ codingPath: [CodingKey]) throws -> UInt64 {
        guard case .natural64(let uInt64) = self else {  throw typeMismatch(codingPath, UInt64.self) }
        return uInt64
    }
    
    func integer(_ codingPath: [CodingKey]) throws -> BigInt {
        guard case .integer(let bigInt) = self else { throw typeMismatch(codingPath, BigInt.self) }
        return bigInt
    }
    
    func integer8(_ codingPath: [CodingKey]) throws -> Int8 {
        guard case .integer8(let int8) = self else { throw typeMismatch(codingPath, Int8.self) }
        return int8
    }
    
    func integer16(_ codingPath: [CodingKey]) throws -> Int16 {
        guard case .integer16(let int16) = self else { throw typeMismatch(codingPath, Int16.self) }
        return int16
    }
    
    func integer32(_ codingPath: [CodingKey]) throws -> Int32 {
        guard case .integer32(let int32) = self else { throw typeMismatch(codingPath, Int32.self) }
        return int32
    }
    
    func integer64(_ codingPath: [CodingKey]) throws -> Int64 {
        guard case .integer64(let int64) = self else { throw typeMismatch(codingPath, Int64.self) }
        return int64
    }
    
    func float32(_ codingPath: [CodingKey]) throws -> Float {
        guard case .float32(let float) = self else { throw typeMismatch(codingPath, Float.self) }
        return float
    }
    
    func float64(_ codingPath: [CodingKey]) throws -> Double {
        guard case .float64(let double) = self else { throw typeMismatch(codingPath, Double.self) }
        return double
    }
    
    func text(_ codingPath: [CodingKey]) throws -> String {
        guard case .text(let string) = self else { throw typeMismatch(codingPath, String.self) }
        return string
    }
    
    func blob(_ codingPath: [CodingKey]) throws -> Data {
        if case .vector(let vector) = self,
           vector.containedType == .natural8 {
            return Data(vector.values.map { $0.natural8Value! })
        }
        if case .blob(let data) = self {
            return data
        }
        throw typeMismatch(codingPath, Data.self)
    }
    
    func principal(_ codingPath: [CodingKey]) throws -> CandidPrincipal {
        guard case .principal(let principal) = self,
              let principal = principal else { throw typeMismatch(codingPath, CandidPrincipal.self) }
        return principal
    }
    
    func function(_ codingPath: [CodingKey]) throws -> CandidFunction {
        guard case .function(let function) = self else { throw typeMismatch(codingPath, CandidFunction.self) }
        return function
    }
    
    func service(_ codingPath: [CodingKey]) throws -> CandidService {
        guard case .service(let service) = self else { throw typeMismatch(codingPath, CandidService.self) }
        return service
    }
    
    var withRemovedOptionals: CandidValue {
        switch self {
        case .option(let option):
            if let value = option.value { return value }
            return self
        default: return self
        }
    }
    
    var hasValue: Bool {
        switch self {
        case .empty, .null, .reserved: return false
        case .option(let option): return option.value != nil && option.value != .null && option.value != .empty && option.value != .reserved
        case .principal(let principal): return principal != nil
        case .function(let function): return function.method != nil
        case .service(let service): return service.principal != nil
        default: return true
        }
    }
    
    var isNil: Bool { !hasValue }
}

private extension CandidKey {
    func toEnumKey() -> CandidKey {
        if stringValue == nil && intValue < 10 {
            return CandidKey("_\(intValue)")
        }
        return self
    }
}

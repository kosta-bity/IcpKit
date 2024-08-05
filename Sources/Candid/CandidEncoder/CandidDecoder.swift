//
//  CandidDecoder.swift
//
//
//  Created by Konstantinos Gaitanis on 18.07.24.
//

import Foundation
import BigInt
import Combine

public class CandidDecoder: TopLevelDecoder {
    public init() {}
    
    public func decode<T>(_ value: CandidValue) throws -> T where T: Decodable {
        return try decode(T.self, from: value)
    }
    
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
            
        } else if T.self is CandidFunctionProtocol.Type {
            let function = try input.function(codingPath)
            guard let method = function.method else {
                throw EncodingError.invalidValue(function, .init(codingPath: codingPath, debugDescription: "No method defined in CandidFunction"))
            }
            let functionProtocol = (T.self as! CandidFunctionProtocol.Type).init(method.principal, method.name, function.signature.annotations.query)
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
        guard let childValue = input.optionValue?.value else {
            throw DecodingError.typeMismatch(T.self, .init(codingPath: codingPath, debugDescription: "not an optional"))
        }
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
        guard let vector = input.vectorValue else {
            throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "not a vector"))
        }
        self.inputVector = vector.values
        self.rootCodingPath = codingPath
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
        values.compactMap {
            if let string = $0.key.string, let stringKey = Key(stringValue: string) { return stringKey }
            return Key(intValue: $0.key.hash)
        }
    }
    private let keys: [CandidContainerKey]
    private let values: [CandidContainerKey: CandidValue]
    
    init(_ input: CandidValue, _ codingPath: [CodingKey]) throws {
        if let record = input.recordValue {
            keys = record.candidSortedItems.map { $0.key }
            values = Dictionary(uniqueKeysWithValues: record.candidSortedItems.map { ($0.key, $0.value) } )
            
        } else if let variant = input.variantValue {
            keys = variant.candidTypes.map { $0.key }
            values = Dictionary(uniqueKeysWithValues: [(variant.key, variant.value)] )
            
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "not a keyed container"))
        }
        self.codingPath = codingPath
    }
    
    func contains(_ key: Key) -> Bool {
        if let int = key.intValue {
            return keys.contains { $0.hash == int }
        }
        return keys.contains { $0.string == key.stringValue }
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
                CandidKeyedItem($0.key.toEnumKey(), $0.value)
            }
            if associatedValueItems.contains(where: { NestedKey(stringValue: $0.key.string ?? "") != nil }) {
                // at least one associatedValue can be mapped to NestedKey
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
    
    private func candidKey(_ key: Key) -> CandidContainerKey {
        if let int = key.intValue { return CandidContainerKey(int) }
        return CandidContainerKey(key.stringValue)
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
    var isNil: Bool {
        switch self {
        case .empty, .null: return true
        case .option(let option): return option.value == nil
        default: return false
        }
    }
    
    func bool(_ codingPath: [CodingKey]) throws -> Bool {
        guard case .bool(let bool) = self else { 
            throw DecodingError.typeMismatch(Bool.self, .init(codingPath: codingPath, debugDescription: "not a Bool"))
         }
        return bool
    }
    
    func natural(_ codingPath: [CodingKey]) throws -> BigUInt {
        guard case .natural(let bigUInt) = self else {  
            throw DecodingError.typeMismatch(BigUInt.self, .init(codingPath: codingPath, debugDescription: "not a BigUInt"))
         }
        return bigUInt
    }
    
    func natural8(_ codingPath: [CodingKey]) throws -> UInt8 {
        guard case .natural8(let uInt8) = self else {  
            throw DecodingError.typeMismatch(UInt8.self, .init(codingPath: codingPath, debugDescription: "not an UInt8"))
         }
        return uInt8
    }
    
    func natural16(_ codingPath: [CodingKey]) throws -> UInt16 {
        guard case .natural16(let uInt16) = self else {  
            throw DecodingError.typeMismatch(UInt16.self, .init(codingPath: codingPath, debugDescription: "not an UInt16"))
         }
        return uInt16
    }
    
    func natural32(_ codingPath: [CodingKey]) throws -> UInt32 {
        guard case .natural32(let uInt32) = self else {  
            throw DecodingError.typeMismatch(UInt32.self, .init(codingPath: codingPath, debugDescription: "not an UInt32"))
         }
        return uInt32
    }
    
    func natural64(_ codingPath: [CodingKey]) throws -> UInt64 {
        guard case .natural64(let uInt64) = self else {  
            throw DecodingError.typeMismatch(UInt64.self, .init(codingPath: codingPath, debugDescription: "not an UInt64"))
         }
        return uInt64
    }
    
    func integer(_ codingPath: [CodingKey]) throws -> BigInt {
        guard case .integer(let bigInt) = self else {  
            throw DecodingError.typeMismatch(BigInt.self, .init(codingPath: codingPath, debugDescription: "not a BigInt"))
         }
        return bigInt
    }
    
    func integer8(_ codingPath: [CodingKey]) throws -> Int8 {
        guard case .integer8(let int8) = self else {  
            throw DecodingError.typeMismatch(Int8.self, .init(codingPath: codingPath, debugDescription: "not an Int8"))
         }
        return int8
    }
    
    func integer16(_ codingPath: [CodingKey]) throws -> Int16 {
        guard case .integer16(let int16) = self else {  
            throw DecodingError.typeMismatch(Int16.self, .init(codingPath: codingPath, debugDescription: "not an Int16"))
         }
        return int16
    }
    
    func integer32(_ codingPath: [CodingKey]) throws -> Int32 {
        guard case .integer32(let int32) = self else {  
            throw DecodingError.typeMismatch(Int32.self, .init(codingPath: codingPath, debugDescription: "not an Int32"))
         }
        return int32
    }
    
    func integer64(_ codingPath: [CodingKey]) throws -> Int64 {
        guard case .integer64(let int64) = self else {  
            throw DecodingError.typeMismatch(Int64.self, .init(codingPath: codingPath, debugDescription: "not an Int64"))
         }
        return int64
    }
    
    func float32(_ codingPath: [CodingKey]) throws -> Float {
        guard case .float32(let float) = self else {  
            throw DecodingError.typeMismatch(Float.self, .init(codingPath: codingPath, debugDescription: "not a Float"))
         }
        return float
    }
    
    func float64(_ codingPath: [CodingKey]) throws -> Double {
        guard case .float64(let double) = self else {  
            throw DecodingError.typeMismatch(Double.self, .init(codingPath: codingPath, debugDescription: "not a Double"))
         }
        return double
    }
    
    func text(_ codingPath: [CodingKey]) throws -> String {
        guard case .text(let string) = self else {  
            throw DecodingError.typeMismatch(String.self, .init(codingPath: codingPath, debugDescription: "not a String"))
         }
        return string
    }
    
    func function(_ codingPath: [CodingKey]) throws -> CandidFunction {
        guard case .function(let function) = self else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: codingPath, debugDescription: "not a Function"))
        }
        return function
    }
    
    func service(_ codingPath: [CodingKey]) throws -> CandidService {
        guard case .service(let service) = self else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: codingPath, debugDescription: "not a Function"))
        }
        return service
    }
}

private extension CandidContainerKey {
    func toEnumKey() -> CandidContainerKey {
        if string == nil {
            return CandidContainerKey("_\(hash)")
        }
        return self
    }
}

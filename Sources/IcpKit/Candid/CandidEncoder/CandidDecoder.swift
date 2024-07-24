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
//        if let option = input.optionValue {
//            if let concreteValue = option.value {
//                let decoder = CandidValueDecoder(concreteValue, codingPath + [IntCodingKey(intValue: 0)])
//                return try decoder.candidDecode()
//            } else {
//                // TODO: throw error if types are incompatible
//                return try T.init(from: self) // will end up calling encodeNil on CandidSingleValueContainer
//            }
//        }
        
        if T.self is BigUInt.Type {
            let bigUInt = try input.natural()
            return bigUInt as! T
            
        } else if T.self is BigInt.Type {
            let bigInt = try input.integer()
            return bigInt as! T
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

private struct IntCodingKey: CodingKey {
    var stringValue: String { return String(intValue!) }
    init?(stringValue: String) { fatalError() }
    let intValue: Int?
    init(intValue: Int) { self.intValue = intValue }
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
        let childValue = getNextValue()
        return KeyedDecodingContainer(try CandidKeyedDecodingContainer<NestedKey>(childValue, codingPath))
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let childValue = getNextValue()
        return try CandidUnkeyedDecodingContainer(childValue, codingPath)
    }
    
    func superDecoder() throws -> Decoder { fatalError("superDecoder not supported") }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let childValue = getNextValue()
        let decoder = CandidValueDecoder(childValue, codingPath)
        return try decoder.candidDecode()
    }
    
    func getNextValue() -> CandidValue {
        let childValue = inputVector[currentIndex]
        currentIndex += 1
        return childValue
    }
}

private class CandidKeyedDecodingContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
    let codingPath: [CodingKey]
    var allKeys: [Key] = []
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
        allKeys = keys.compactMap {
            if let string = $0.string, let stringKey = Key(stringValue: string) { return stringKey }
            return Key(intValue: $0.hash)
        }
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
                return CandidKeyedItem($0.key.toEnumKey(), $0.value)
            }
            associatedCandidValue = .record(associatedValueItems)
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
    func decode(_ type: Bool.Type) throws -> Bool { try input.bool() }
    func decode(_ type: String.Type) throws -> String { try input.text() }
    
    // TODO: convert from compatible types where possible
    func decode(_ type: Double.Type) throws -> Double { try input.float64() }
    func decode(_ type: Float.Type) throws -> Float { try input.float32() }
    func decode(_ type: Int.Type) throws -> Int { Int(try input.integer64()) }
    func decode(_ type: Int8.Type) throws -> Int8 { try input.integer8() }
    func decode(_ type: Int16.Type) throws -> Int16 { try input.integer16() }
    func decode(_ type: Int32.Type) throws -> Int32 { try input.integer32() }
    func decode(_ type: Int64.Type) throws -> Int64 { try input.integer64() }
    func decode(_ type: UInt.Type) throws -> UInt { UInt(try input.natural64()) }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try input.natural8() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try input.natural16() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try input.natural32() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try input.natural64() }
}

extension CandidUnkeyedDecodingContainer {
    func decodeNil() throws -> Bool { throw DecodingError.typeMismatch(Any?.self, .init(codingPath: codingPath, debugDescription: "not an optional")) }
    func decode(_ type: Bool.Type) throws -> Bool { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not a Bool")) }
    func decode(_ type: String.Type) throws -> String { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not a String")) }
    func decode(_ type: Double.Type) throws -> Double { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not a Double")) }
    func decode(_ type: Float.Type) throws -> Float { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not a Float")) }
    func decode(_ type: Int.Type) throws -> Int { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int")) }
    func decode(_ type: Int8.Type) throws -> Int8 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int8")) }
    func decode(_ type: Int16.Type) throws -> Int16 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int16")) }
    func decode(_ type: Int32.Type) throws -> Int32 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int32")) }
    func decode(_ type: Int64.Type) throws -> Int64 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int64")) }
    func decode(_ type: UInt.Type) throws -> UInt { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt")) }
    func decode(_ type: UInt8.Type) throws -> UInt8 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt8")) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt16")) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt32")) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt64")) }
}

extension CandidKeyedDecodingContainer {
    func decodeNil(forKey key: Key) throws -> Bool {
        return try value(key).isNil
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let value = try value(key).boolValue else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not a Bool"))
        }
        return value
    }
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let value = try value(key).textValue else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not a String"))
        }
        return value
    }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let value = try value(key).float64Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Double"))
        }
        return value
    }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let value = try value(key).float32Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Float"))
        }
        return value
    }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let value = try value(key).integer64Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int"))
        }
        return Int(value)
    }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let value = try value(key).integer8Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int8"))
        }
        return value
    }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let value = try value(key).integer16Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int16"))
        }
        return value
    }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let value = try value(key).integer32Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int32"))
        }
        return value
    }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let value = try value(key).integer64Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an Int64"))
        }
        return value
    }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let value = try value(key).natural64Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt"))
        }
        return UInt(value)
    }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let value = try value(key).natural8Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt8"))
        }
        return value
    }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let value = try value(key).natural16Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt16"))
        }
        return value
    }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let value = try value(key).natural32Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt32"))
        }
        return value
    }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let value = try value(key).natural64Value else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "not an UInt64"))
        }
        return value
    }
}

private extension CandidValue {
    var isNil: Bool {
        switch self {
        case .empty, .null: return true
        case .option(let option): return option.value == nil
        default: return false
        }
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

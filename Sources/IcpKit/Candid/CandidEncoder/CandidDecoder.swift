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
        return try CandidSingleValueDecodingContainer(input, codingPath)
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
    let decodingValue: CandidSingleDecodingValue
    let input: CandidValue
    
    init(_ input: CandidValue, _ codingPath: [CodingKey]) throws {
        guard let decodingValue = CandidSingleDecodingValue(input) else {
            throw CandidDecoderError.invalidContainer
        }
        self.decodingValue = decodingValue
        self.input = input
        self.codingPath = codingPath
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let childValue = try decodingValue.childCandidValue()
        let decoder = CandidValueDecoder(childValue, codingPath + [IntCodingKey(intValue: 0)])
        return try decoder.candidDecode()
    }
}

private class CandidUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey]
    var count: Int? { inputVector.count }
    var isAtEnd: Bool { currentIndex == count }
    private let inputVector: [CandidValue]
    private (set) var currentIndex: Int = 0
    private var currentCodingPath: [CodingKey] { codingPath + [IntCodingKey(intValue: currentIndex)] }
    
    init(_ input: CandidValue, _ codingPath: [CodingKey]) throws {
        guard let vector = input.vectorValue else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "not a vector"))
        }
        self.codingPath = codingPath
        self.inputVector = vector.values
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let childValue = getNextValue()
        return KeyedDecodingContainer(try CandidKeyedDecodingContainer<NestedKey>(childValue, currentCodingPath))
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let childValue = getNextValue()
        return try CandidUnkeyedDecodingContainer(childValue, currentCodingPath)
    }
    
    func superDecoder() throws -> Decoder { fatalError("superDecoder not supported") }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let childValue = getNextValue()
        let decoder = CandidValueDecoder(childValue, currentCodingPath)
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
    func decodeNil() -> Bool { decodingValue.isNil }
    func decode(_ type: Bool.Type) throws -> Bool { try decodingValue.bool() }
    func decode(_ type: String.Type) throws -> String { try decodingValue.text() }
    
    // TODO: convert from compatible types where possible
    func decode(_ type: Double.Type) throws -> Double { try decodingValue.float64() }
    func decode(_ type: Float.Type) throws -> Float { try decodingValue.float32() }
    func decode(_ type: Int.Type) throws -> Int { try decodingValue.integer() }
    func decode(_ type: Int8.Type) throws -> Int8 { try decodingValue.integer() }
    func decode(_ type: Int16.Type) throws -> Int16 { try decodingValue.integer() }
    func decode(_ type: Int32.Type) throws -> Int32 { try decodingValue.integer() }
    func decode(_ type: Int64.Type) throws -> Int64 { try decodingValue.integer() }
    func decode(_ type: UInt.Type) throws -> UInt { try decodingValue.natural() }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try decodingValue.natural() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try decodingValue.natural() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try decodingValue.natural() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try decodingValue.natural() }
}

extension CandidUnkeyedDecodingContainer {
    func decodeNil() throws -> Bool { fatalError() }
    func decode(_ type: Bool.Type) throws -> Bool { fatalError() }
    func decode(_ type: String.Type) throws -> String { fatalError() }
    func decode(_ type: Double.Type) throws -> Double { fatalError() }
    func decode(_ type: Float.Type) throws -> Float { fatalError() }
    func decode(_ type: Int.Type) throws -> Int { fatalError() }
    func decode(_ type: Int8.Type) throws -> Int8 { fatalError() }
    func decode(_ type: Int16.Type) throws -> Int16 { fatalError() }
    func decode(_ type: Int32.Type) throws -> Int32 { fatalError() }
    func decode(_ type: Int64.Type) throws -> Int64 { fatalError() }
    func decode(_ type: UInt.Type) throws -> UInt { fatalError() }
    func decode(_ type: UInt8.Type) throws -> UInt8 { fatalError() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { fatalError() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { fatalError() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { fatalError() }
}

extension CandidKeyedDecodingContainer {
    func decodeNil(forKey key: Key) throws -> Bool {
        if let optionValue = try value(key).optionValue {
            return optionValue.value == nil
        }
        return false
    }
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { try value(key).bool() }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { try value(key).text() }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { try value(key).float64() }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float { try value(key).float32() }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int { Int(try value(key).integer64()) }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { try value(key).integer8() }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { try value(key).integer16() }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { try value(key).integer32() }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { try value(key).integer64() }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { UInt(try value(key).natural64()) }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { try value(key).natural8() }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { try value(key).natural16() }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { try value(key).natural32() }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { try value(key).natural64() }
}

private extension CandidValue {
    var isSingleValue: Bool {
        switch self {
        case .null, .bool, .natural, .integer, .natural8, .natural16, .natural32, .natural64, .integer8, .integer16, .integer32, .integer64, .float32, .float64, .text, .option:
            return true
            
        case .reserved, .empty, .blob, .vector, .record, .variant, .function, .service, .principal:
            return false
        }
    }
}

enum CandidSingleDecodingValue {
    case empty
    case bool(Bool)
    case null(CandidType)
    case anyInteger(any BinaryInteger)
    case anyNatural(any UnsignedInteger)
    case anyFloat(Double)
    case text(String)
    case candidValue(CandidValue)
    
    func childCandidValue() throws -> CandidValue {
        guard case .candidValue(let candidValue) = self else {
            throw CandidDecoderError.invalidContainer
        }
        return candidValue
    }
    
    init?(_ value: CandidValue) {
        switch value {
        case .null: self = .empty
        case .bool(let bool): self = .bool(bool)
        case .natural(let bigUInt): self = .anyNatural(bigUInt)
        case .integer(let bigInt): self = .anyInteger(bigInt)
        case .natural8(let uInt8): self = .anyNatural(uInt8)
        case .natural16(let uInt16): self = .anyNatural(uInt16)
        case .natural32(let uInt32): self = .anyNatural(uInt32)
        case .natural64(let uInt64): self = .anyNatural(uInt64)
        case .integer8(let int8): self = .anyInteger(int8)
        case .integer16(let int16): self = .anyInteger(int16)
        case .integer32(let int32): self = .anyInteger(int32)
        case .integer64(let int64): self = .anyInteger(int64)
        case .float32(let float): self = .anyFloat(Double(float))
        case .float64(let double): self = .anyFloat(double)
        case .text(let string): self = .text(string)
        case .option(let candidOption):
            if let wrappedValue = candidOption.value {
                self = .candidValue(wrappedValue)
            } else {
                self = .null(candidOption.containedType)
            }
        default:
            return nil
        }
    }
    
    var isNil: Bool {
        switch self {
        case .empty, .null: return true
        default: return false
        }
    }
    
    func bool() throws -> Bool {
        guard case .bool(let bool) = self else { throw CandidDecoderError.invalidContainer }
        return bool
    }
    
    func natural<T>() throws -> T where T: UnsignedInteger {
        guard case .anyNatural(let unsignedInt) = self,
              let uint = T(exactly: unsignedInt) else {  throw CandidDecoderError.invalidContainer }
        return uint
    }
    
    func integer<T>() throws -> T where T: BinaryInteger {
        guard case .anyInteger(let binInt) = self,
              let int = T(exactly: binInt) else {  throw CandidDecoderError.invalidContainer }
        return int
    }
    
    func float32() throws -> Float {
        guard case .anyFloat(let float) = self else {  throw CandidDecoderError.invalidContainer }
        return Float(float)
    }
    
    func float64() throws -> Double {
        guard case .anyFloat(let double) = self else {  throw CandidDecoderError.invalidContainer }
        return double
    }
    
    func text() throws -> String {
        guard case .text(let string) = self else {  throw CandidDecoderError.invalidContainer }
        return string
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

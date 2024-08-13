//
//  CandidValue+Init.swift
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation
import BigInt

public extension CandidValue {
    init(_ bool: Bool) { self = .bool(bool) }
    init(_ text: String) { self = .text(text) }
    init(_ blob: Data) { self = .blob(blob) }
    init(_ natural8: UInt8) { self = .natural8(natural8) }
    init(_ natural16: UInt16) { self = .natural16(natural16) }
    init(_ natural32: UInt32) { self = .natural32(natural32) }
    init(_ natural64: UInt64) { self = .natural64(natural64) }
    init(_ natural64: UInt) { self = .natural64(UInt64(natural64)) }
    init(_ integer8: Int8) { self = .integer8(integer8) }
    init(_ integer16: Int16) { self = .integer16(integer16) }
    init(_ integer32: Int32) { self = .integer32(integer32) }
    init(_ integer64: Int64) { self = .integer64(integer64) }
    init(_ integer64: Int) { self = .integer64(Int64(integer64)) }
    init(_ integer: BigInt) { self = .integer(integer) }
    init(_ natural: BigUInt) { self = .natural(natural) }
    init(_ bool: Bool?) { self = .option(.bool, bool.map { CandidValue.bool($0) }) }
    init(_ text: String?) { self = .option(.text, text.map { CandidValue.text($0) }) }
    init(_ blob: Data?) { self = .option(.blob, blob.map { CandidValue.blob($0) }) }
    init(_ natural8: UInt8?) { self = .option(.natural8, natural8.map { CandidValue.natural8($0) }) }
    init(_ natural16: UInt16?) { self = .option(.natural16, natural16.map { CandidValue.natural16($0) }) }
    init(_ natural32: UInt32?) { self = .option(.natural32, natural32.map { CandidValue.natural32($0) }) }
    init(_ natural64: UInt64?) { self = .option(.natural64, natural64.map { CandidValue.natural64($0) }) }
    init(_ natural64: UInt?) { self = .option(.natural64, natural64.map { CandidValue.natural64(UInt64($0)) }) }
    init(_ integer8: Int8?) { self = .option(.integer8, integer8.map { CandidValue.integer8($0) }) }
    init(_ integer16: Int16?) { self = .option(.integer16, integer16.map { CandidValue.integer16($0) }) }
    init(_ integer32: Int32?) { self = .option(.integer32, integer32.map { CandidValue.integer32($0) }) }
    init(_ integer64: Int64?) { self = .option(.integer64, integer64.map { CandidValue.integer64($0) }) }
    init(_ integer64: Int?) { self = .option(.integer64, integer64.map { CandidValue.integer64(Int64($0)) }) }
    init(_ integer: BigInt?) { self = .option(.integer, integer.map { CandidValue.integer($0) }) }
    init(_ natural: BigUInt?) { self = .option(.natural, natural.map { CandidValue.natural($0) }) }
    
    static func option(_ value: CandidValue) -> CandidValue {
        return .option(.some(value))
    }
    
    static func option(_ containedType: CandidType) -> CandidValue {
        return .option(.none(containedType))
    }
    
    static func option(_ containedType: CandidType, _ value: CandidValue?) -> CandidValue {
        guard let value = value else {
            return .option(containedType)
        }
        return .option(value)
    }
    
    static func vector(_ containedType: CandidType) -> CandidValue {
        return .vector(CandidVector(containedType))
    }
    
    static func vector(_ items: any Sequence<CandidValue>) throws -> CandidValue {
        return try .vector(CandidVector(items))
    }
    
    static func variant(_ items: [String: CandidType], _ value: (String, CandidValue)) throws -> CandidValue {
        return .variant(try CandidVariant(
            candidTypes: items.map { ($0.key, $0.value) },
            value: value
        ))
    }
    
    static func variant(_ items: [Int: CandidType], _ value: CandidValue, _ valueKey: Int) throws -> CandidValue {
        return .variant(try CandidVariant(
            candidTypes: items.map { CandidKeyedType($0.key, $0.value) },
            value: value,
            valueKey: valueKey
        ))
    }
    
    static func variant(_ value: CandidKeyedValue) -> CandidValue {
        return .variant(CandidVariant(candidTypes: [.init(value)], value: value.value, valueIndex: 0))
    }
    
    static func record(_ items: any Sequence<CandidKeyedValue> = []) -> CandidValue {
        return .record(CandidRecord(items))
    }

    static func record(_ items: any Sequence<CandidValue>) -> CandidValue {
        return .record(CandidRecord(items))
    }
    
    static func record(_ items: [Int: CandidValue]) -> CandidValue {
        return .record(CandidRecord(items))
    }
    
    static func principal(_ string: String) throws -> CandidValue {
        return .principal(try CandidPrincipal(string))
    }
    
    static func principal(_ bytes: Data) -> CandidValue {
        return .principal(CandidPrincipal(bytes))
    }
    
    static func function(_ inputs: [CandidFunctionSignature.Parameter], _ outputs: [CandidFunctionSignature.Parameter], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false) -> CandidValue {
        .function(CandidFunction(signature: CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay, compositeQuery: compositeQuery), method: nil))
    }
    
    static func function(_ inputs: [CandidType], _ outputs: [CandidType], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false) -> CandidValue {
        .function(CandidFunction(signature: CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay, compositeQuery: compositeQuery), method: nil))
    }
    
    static func function(_ inputs: [CandidType], _ outputs: [CandidType], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false, _ principal: String, _ methodName: String) throws -> CandidValue {
        .function(CandidFunction(signature: CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay, compositeQuery: compositeQuery), method: .init(name: methodName, principal: try CandidPrincipal(principal))))
    }
    
    static func function(_ inputs: [CandidType], _ outputs: [CandidType], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false, _ principal: any CandidPrincipalProtocol, _ methodName: String) -> CandidValue {
        .function(CandidFunction(signature: CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay, compositeQuery: compositeQuery), method: .init(name: methodName, principal: CandidPrincipal(principal))))
    }
    
    static func function(_ principal: String, _ methodName: String) throws -> CandidValue {
        try .function([], [], principal, methodName)
    }
    
    static func service(_ methods: [CandidServiceSignature.Method], _ principal: String) throws -> CandidValue {
        try .service(CandidService(principal: CandidPrincipal(principal), signature: CandidServiceSignature(methods)))
    }
    
    static func service(_ methods: [CandidServiceSignature.Method], _ principal: any CandidPrincipalProtocol) -> CandidValue {
        .service(CandidService(principal: CandidPrincipal(principal), signature: CandidServiceSignature(methods)))
    }
    
    static func service(_ principal: String) throws -> CandidValue {
        try .service(CandidService(principal: CandidPrincipal(principal), signature: CandidServiceSignature([])))
    }
    
    static func service(_ methods: [CandidServiceSignature.Method]) -> CandidValue {
        .service(CandidService(principal: nil, signature: CandidServiceSignature(methods)))
    }
}

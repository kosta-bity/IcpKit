//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

public extension CandidType {
    static let null: CandidType = .primitive(.null)
    static let bool: CandidType = .primitive(.bool)
    static let natural: CandidType = .primitive(.natural)
    static let integer: CandidType = .primitive(.integer)
    static let natural8: CandidType = .primitive(.natural8)
    static let natural16: CandidType = .primitive(.natural16)
    static let natural32: CandidType = .primitive(.natural32)
    static let natural64: CandidType = .primitive(.natural64)
    static let integer8: CandidType = .primitive(.integer8)
    static let integer16: CandidType = .primitive(.integer16)
    static let integer32: CandidType = .primitive(.integer32)
    static let integer64: CandidType = .primitive(.integer64)
    static let float32: CandidType = .primitive(.float32)
    static let float64: CandidType = .primitive(.float64)
    static let text: CandidType = .primitive(.text)
    static let reserved: CandidType = .primitive(.reserved)
    static let empty: CandidType = .primitive(.empty)
    static let principal: CandidType = .primitive(.principal)
    
    static func option(_ containedType: CandidType) -> CandidType { .container(.option, containedType) }
    static func vector(_ containedType: CandidType) -> CandidType { .container(.vector, containedType) }
    
    static func variant(_ containedTypes: [CandidKeyedItemType] = []) -> CandidType { .keyedContainer(.variant, containedTypes.keyHashSorted()) }
    static func variant(_ containedTypes: (String, CandidType) ...) -> CandidType {
        .keyedContainer(.variant, containedTypes.map { CandidKeyedItemType($0.0, $0.1) }.keyHashSorted())
    }
    static func variant(_ containedTypes: [String: CandidType]) -> CandidType {
        .keyedContainer(.variant, containedTypes.map { CandidKeyedItemType($0.0, $0.1) }.keyHashSorted())
    }
    static func variant(_ containedTypes: [Int: CandidType]) -> CandidType {
        .keyedContainer(.variant, containedTypes.map { CandidKeyedItemType(hashedKey: $0.0, type: $0.1) }.keyHashSorted())
    }
    
    static func record(_ containedTypes: [CandidKeyedItemType] = []) -> CandidType { .keyedContainer(.record, containedTypes.keyHashSorted()) }
    static func record(_ containedTypes: (String, CandidType) ...) -> CandidType {
        .keyedContainer(.record, containedTypes.map { CandidKeyedItemType($0.0, $0.1) }.keyHashSorted())
    }
    static func record(_ containedTypes: [String: CandidType]) -> CandidType {
        .keyedContainer(.record, containedTypes.map { CandidKeyedItemType($0.0, $0.1) }.keyHashSorted())
    }
    static func record(_ containedTypes: [Int: CandidType]) -> CandidType {
        .keyedContainer(.record, containedTypes.map { CandidKeyedItemType(hashedKey: $0.0, type: $0.1) }.keyHashSorted())
    }
    
    static func function(_ inputs: [CandidFunctionSignature.Parameter] = [], _ outputs: [CandidFunctionSignature.Parameter] = [], query: Bool = false, oneWay: Bool = false) -> CandidType {
        .function(CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay))
    }
    
    static func function(_ inputs: [CandidType], _ outputs: [CandidType], query: Bool = false, oneWay: Bool = false) -> CandidType {
        .function(CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay))
    }
    
    static func service(_ name: String? = nil, _ methods: [CandidServiceSignature.Method] = []) -> CandidType {
        .service(CandidServiceSignature(initialisationArguments: nil, name: name, methods: methods))
    }
}

private extension Sequence<CandidKeyedItemType> {
    func keyHashSorted() -> [CandidKeyedItemType] { sorted { $0.key.hash < $1.key.hash } }
}

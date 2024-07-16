//
//  CandidType+Init.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

public extension CandidType {
    static func variant(_ containedTypes: [CandidKeyedItemType]) -> CandidType {
        return .variant(CandidKeyedTypes(containedTypes))
    }
    static func variant(_ containedTypes: (String, CandidType) ...) -> CandidType {
        .variant(containedTypes.map { CandidKeyedItemType($0.0, $0.1) })
    }
    static func variant(_ containedTypes: [String: CandidType]) -> CandidType {
        .variant(containedTypes.map { CandidKeyedItemType($0.0, $0.1) })
    }
    static func variant(_ containedTypes: [Int: CandidType]) -> CandidType {
        .variant(containedTypes.map { CandidKeyedItemType(hashedKey: $0.0, type: $0.1) })
    }
    
    static func record(_ containedTypes: [CandidKeyedItemType]) -> CandidType {
        return .record(CandidKeyedTypes(containedTypes))
    }
    static func record(_ containedTypes: (String, CandidType) ...) -> CandidType {
        .record(containedTypes.map { CandidKeyedItemType($0.0, $0.1) })
    }
    static func record(_ containedTypes: [String: CandidType]) -> CandidType {
        .record(containedTypes.map { CandidKeyedItemType($0.0, $0.1) })
    }
    static func record(_ containedTypes: [Int: CandidType]) -> CandidType {
        .record(containedTypes.map { CandidKeyedItemType(hashedKey: $0.0, type: $0.1) })
    }
    
    static func function(_ inputs: [CandidFunctionSignature.Parameter] = [], _ outputs: [CandidFunctionSignature.Parameter] = [], query: Bool = false, oneWay: Bool = false) -> CandidType {
        .function(CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay))
    }
    
    static func function(_ inputs: [CandidType], _ outputs: [CandidType], query: Bool = false, oneWay: Bool = false) -> CandidType {
        .function(CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay))
    }

    static func service(_ methods: [CandidServiceSignature.Method] = []) -> CandidType {
        .service(CandidServiceSignature(methods))
    }
}

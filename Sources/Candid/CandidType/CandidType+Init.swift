//
//  CandidType+Init.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

public extension CandidType {
    static var blob: CandidType {
        return .vector(.natural8)
    }
    static func variant(_ containedTypes: [CandidKeyedType]) -> CandidType {
        return .variant(CandidKeyedTypes(containedTypes))
    }
    static func variant(_ containedTypes: (String, CandidType) ...) -> CandidType {
        .variant(containedTypes.map { CandidKeyedType($0.0, $0.1) })
    }
    static func variant(_ containedTypes: [String: CandidType]) -> CandidType {
        .variant(containedTypes.map { CandidKeyedType($0.0, $0.1) })
    }
    static func variant(_ containedTypes: [Int: CandidType]) -> CandidType {
        .variant(containedTypes.map { CandidKeyedType($0.0, $0.1) })
    }
    static func variant(_ containedTypes: String...) -> CandidType {
        .variant(containedTypes.map { CandidKeyedType($0, .null) })
    }
    
    static func record(_ containedTypes: [CandidType]) -> CandidType {
        return .record(CandidKeyedTypes(containedTypes))
    }
    static func record(_ containedTypes: [CandidKeyedType]) -> CandidType {
        return .record(CandidKeyedTypes(containedTypes))
    }
    static func record(_ containedTypes: (String, CandidType) ...) -> CandidType {
        .record(containedTypes.map { CandidKeyedType($0.0, $0.1) })
    }
    static func record(_ containedTypes: [String: CandidType]) -> CandidType {
        .record(containedTypes.map { CandidKeyedType($0.0, $0.1) })
    }
    static func record(_ containedTypes: [Int: CandidType]) -> CandidType {
        .record(containedTypes.map { CandidKeyedType($0.0, $0.1) })
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
    
    static func service(_ methods: [String: CandidFunctionSignature]) -> CandidType {
        .service(CandidServiceSignature(methods.map { .init(name: $0.key, signatureType: .concrete($0.value)) } ))
    }
}

//
//  CandidValue+Init.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation

public extension CandidValue {
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
    
    static func principal(_ string: String) throws -> CandidValue {
        return .principal(try CandidPrincipal(string))
    }
    
    static func principal(_ bytes: Data) -> CandidValue {
        return .principal(CandidPrincipal(bytes))
    }
    
    static func function(_ inputs: [CandidFunctionSignature.Parameter], _ outputs: [CandidFunctionSignature.Parameter], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false) -> CandidValue {
        .function(CandidFunction(signature: CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay, compositeQuery: compositeQuery), method: nil))
    }
    
    static func function(_ inputs: [CandidType] = [], _ outputs: [CandidType] = [], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false) -> CandidValue {
        .function(CandidFunction(signature: CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay, compositeQuery: compositeQuery), method: nil))
    }
    
    static func function(_ inputs: [CandidType] = [], _ outputs: [CandidType] = [], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false, _ principal: String, _ methodName: String) throws -> CandidValue {
        .function(CandidFunction(signature: CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneWay, compositeQuery: compositeQuery), method: .init(name: methodName, principal: try CandidPrincipal(principal))))
    }
    
    
    static func service(_ methods: [CandidServiceSignature.Method] = [], _ principal: String) throws -> CandidValue {
        try .service(CandidService(principal: CandidPrincipal(principal), signature: CandidServiceSignature(methods)))
    }
    
    static func service(_ methods: [CandidServiceSignature.Method]) -> CandidValue {
        .service(CandidService(principal: nil, signature: CandidServiceSignature(methods)))
    }
}

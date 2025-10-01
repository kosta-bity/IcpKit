//
//  CandidServiceSignature.swift
//  
//
//  Created by Konstantinos Gaitanis on 07.08.24.
//

import Foundation

public struct CandidServiceSignature: Equatable, Codable, Sendable {
    public struct Method: Equatable, Codable, Sendable {
        public enum FunctionSignatureType: Equatable, Codable, Sendable {
            case concrete(CandidFunctionSignature)
            case reference(String)
        }
        public let name: String
        public let functionSignature: FunctionSignatureType
        
        public init(name: String, signatureType: FunctionSignatureType) {
            self.name = name
            self.functionSignature = signatureType
        }
        
        public init(name: String, functionSignature: CandidFunctionSignature) {
            self.name = name
            self.functionSignature = .concrete(functionSignature)
        }
        
        public init(name: String, signatureReference: String) {
            self.name = name
            self.functionSignature = .reference(signatureReference)
        }
        
        public init(_ name: String, _ arguments: [CandidType] = [], _ results: [CandidType] = [], query: Bool = false, oneway: Bool = false, compositeQuery: Bool = false) {
            self.name = name
            self.functionSignature = .concrete(CandidFunctionSignature(arguments, results, query: query, oneWay: oneway, compositeQuery: compositeQuery))
        }
        
        public init(_ name: String, _ arguments: [(String?, CandidType)], _ results: [(String?, CandidType)], query: Bool = false, oneway: Bool = false, compositeQuery: Bool = false) {
            self.name = name
            self.functionSignature = .concrete(CandidFunctionSignature(arguments, results, query: query, oneWay: oneway, compositeQuery: compositeQuery))
        }
    }
    public let methods: [Method]
    
    public init(_ methods: [Method]) {
        self.methods = methods
    }
}

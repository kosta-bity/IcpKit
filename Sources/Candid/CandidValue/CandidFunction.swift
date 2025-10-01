//
//  CandidFunction.swift
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public struct CandidFunction: Equatable, Codable, Sendable {
    public let signature: CandidFunctionSignature
    public let method: ServiceMethod?
    
    public init(signature: CandidFunctionSignature, method: ServiceMethod?) {
        self.signature = signature
        self.method = method
    }
    
    public init(signature: CandidFunctionSignature, principal: CandidPrincipal, methodName: String) {
        self.signature = signature
        self.method = .init(name: methodName, principal: principal)
    }
    
    public struct ServiceMethod: Equatable, Codable, Sendable {
        public let name: String
        public let principal: CandidPrincipal
        
        public init(name: String, principal: CandidPrincipal) {
            self.name = name
            self.principal = principal
        }
        
        public init(name: String, principal: String) throws {
            self.name = name
            self.principal = try CandidPrincipal(principal)
        }
    }
}

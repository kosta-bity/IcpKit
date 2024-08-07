//
//  CandidFunction.swift
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public struct CandidFunction: Equatable, Codable {
    public let signature: CandidFunctionSignature
    public let method: ServiceMethod?
    
    public init(signature: CandidFunctionSignature, method: ServiceMethod?) {
        self.signature = signature
        self.method = method
    }
    
    public struct ServiceMethod: Equatable, Codable {
        public let name: String
        public let principal: CandidPrincipal
        
        public init(name: String, principal: CandidPrincipal) {
            self.name = name
            self.principal = principal
        }
    }
}

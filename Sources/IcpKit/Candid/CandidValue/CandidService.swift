//
//  CandidService.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public struct CandidService: Equatable {
    public let principal: CandidPrincipal?
    public let signature: CandidServiceSignature
}

public struct CandidServiceSignature: Equatable {
    public struct Method: Equatable {
        public let name: String
        public let functionSignature: CandidFunctionSignature
        
        public init(name: String, functionSignature: CandidFunctionSignature) {
            self.name = name
            self.functionSignature = functionSignature
        }
        
        public init(_ name: String, _ arguments: [CandidType], _ results: [CandidType], query: Bool = false, oneway: Bool = false, compositeQuery: Bool = false) {
            self.name = name
            self.functionSignature = CandidFunctionSignature(arguments, results, query: query, oneWay: oneway, compositeQuery: compositeQuery)
        }
    }
    
    public let initialisationArguments: [CandidFunctionSignature.Parameter]?
    public let name: String?
    public let methods: [Method]
}

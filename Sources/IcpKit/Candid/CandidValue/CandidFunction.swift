//
//  CandidFunction.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public struct CandidFunction: Equatable {
    public let signature: CandidFunctionSignature
    public let method: ServiceMethod?
    
    public struct ServiceMethod: Equatable {
        public let name: String
        public let principalId: Data
    }
}

public struct CandidFunctionSignature: Equatable {
    /// https://internetcomputer.org/docs/current/developer-docs/smart-contracts/candid/candid-concepts#naming-arguments-and-results
    /// Naming the arguments or results for a method is purely for documentation purposes.
    /// The name you use does not change the method’s type or the values being passed.
    /// Instead, arguments and results are identified by their position, independent of the name.
    public struct Parameter: Equatable {
        let index: Int
        let name: String?
        let type: CandidType
        
        public static func ==(lhs: Parameter, rhs: Parameter) -> Bool {
            return lhs.index == rhs.index && lhs.type == rhs.type
        }
    }
    public let arguments: [Parameter]
    public let results: [Parameter]
    
    /// indicates that the referenced function is a query method,
    /// meaning it does not alter the state of its canister, and that
    /// it can be invoked using the cheaper “query call” mechanism.
    public let query: Bool
    /// indicates that this function returns no response, intended for fire-and-forget scenarios.
    public let oneWay: Bool
    
    public init(inputs: [Parameter], outputs: [Parameter], query: Bool, oneWay: Bool) {
        self.arguments = inputs.sorted { $0.index < $1.index }
        self.results = outputs.sorted { $0.index < $1.index }
        self.query = query
        self.oneWay = oneWay
    }
    
    public init(inputs: [CandidType], outputs: [CandidType], query: Bool, oneWay: Bool) {
        self.arguments = inputs.enumerated().map { Parameter(index: $0.offset, name: nil, type: $0.element) }
        self.results = outputs.enumerated().map { Parameter(index: $0.offset, name: nil, type: $0.element) }
        self.query = query
        self.oneWay = oneWay
    }
}

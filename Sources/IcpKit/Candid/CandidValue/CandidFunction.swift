//
//  CandidFunction.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public struct CandidFunction: Equatable, Encodable {
    public let signature: CandidFunctionSignature
    public let method: ServiceMethod?
    
    public init(signature: CandidFunctionSignature, method: ServiceMethod?) {
        self.signature = signature
        self.method = method
    }
    
    public struct ServiceMethod: Equatable, Encodable {
        public let name: String
        public let principal: CandidPrincipal
        
        public init(name: String, principal: CandidPrincipal) {
            self.name = name
            self.principal = principal
        }
    }
}

public struct CandidFunctionSignature: Equatable, Encodable {
    /// https://internetcomputer.org/docs/current/developer-docs/smart-contracts/candid/candid-concepts#naming-arguments-and-results
    /// Naming the arguments or results for a method is purely for documentation purposes.
    /// The name you use does not change the method’s type or the values being passed.
    /// Instead, arguments and results are identified by their position, independent of the name.
    public struct Parameter: Equatable, Comparable, Encodable {
        public let index: Int
        public let name: String?
        public let type: CandidType
        
        public static func ==(lhs: Parameter, rhs: Parameter) -> Bool {
            lhs.index == rhs.index && lhs.type == rhs.type
        }
        public static func < (lhs: CandidFunctionSignature.Parameter, rhs: CandidFunctionSignature.Parameter) -> Bool {
            lhs.index < rhs.index
        }
        
        public init(index: Int, name: String?, type: CandidType) {
            self.index = index
            self.name = name
            self.type = type
        }
    }
    
    public struct Annotations: Equatable, Encodable {
        /// indicates that the referenced function is a query method,
        /// meaning it does not alter the state of its canister, and that
        /// it can be invoked using the cheaper “query call” mechanism.
        public let query: Bool
        
        /// indicates that this function returns no response, intended for fire-and-forget scenarios.
        public let oneWay: Bool
        
        /// composite_query is a special query function that has IC-specific features and limitations:
        ///  - composite_query function can only call other composite_query and query functions.
        ///  - composite_query function can only be called from other composite_query functions (not callable from query or update functions) and from outside of IC. Therefore, query is not a subtype of composite_query.
        ///  - composite_query cannot be made cross-subnets.
        ///  - All these limitations are temporary due to the implementation. Eventually, query and composite_query functions will become the same thing.
        public let compositeQuery: Bool
    }
    
    public let arguments: [Parameter]
    public let results: [Parameter]
    public let annotations: Annotations
    
    
    public init(_ inputs: [Parameter], _ outputs: [Parameter], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false) {
        self.arguments = inputs.sorted()
        self.results = outputs.sorted()
        annotations = Annotations(query: query, oneWay: oneWay, compositeQuery: compositeQuery)
    }
    
    public init(_ inputs: [(String?, CandidType)], _ outputs: [(String?, CandidType)], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false) {
        self.arguments = inputs.enumerated().map { Parameter(index: $0.offset, name: $0.element.0, type: $0.element.1) }
        self.results = outputs.enumerated().map { Parameter(index: $0.offset, name: $0.element.0, type: $0.element.1) }
        annotations = Annotations(query: query, oneWay: oneWay, compositeQuery: compositeQuery)
    }
    
    public init(_ inputs: [CandidType], _ outputs: [CandidType], query: Bool = false, oneWay: Bool = false, compositeQuery: Bool = false) {
        self.arguments = inputs.enumerated().map { Parameter(index: $0.offset, name: nil, type: $0.element) }
        self.results = outputs.enumerated().map { Parameter(index: $0.offset, name: nil, type: $0.element) }
        annotations = Annotations(query: query, oneWay: oneWay, compositeQuery: compositeQuery)
    }
}

//
//  ICPFunction.swift
//
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation
import Candid


public extension CandidFunctionProtocol {
    init(_ canister: ICPPrincipal, _ method: String, query: Bool) {
        self.init(CandidPrincipal(canister.bytes), method, query)
    }
    
    var icpPrincipal: ICPPrincipal { ICPPrincipal(canister) }
}

fileprivate extension CandidFunctionProtocol {
    func callOrQuery(_ method: ICPMethod, _ client: ICPRequestClient, _ sender: ICPSigningPrincipal?) async throws -> CandidValue {
        if query {
            return try await client.query(method, effectiveCanister: icpPrincipal, sender: sender)
        } else {
            return try await client.callAndPoll(method, effectiveCanister: icpPrincipal, sender: sender)
        }
    }
}

public struct ICPFunction<Argument, Result>: CandidFunctionProtocol where Argument: Encodable, Result: Decodable {
    public let canister: CandidPrincipal
    public let method: String
    public let query: Bool
    
    public init(_ canister: CandidPrincipal, _ method: String, _ query: Bool) {
        self.canister = canister
        self.method = method
        self.query = query
    }
    
    public func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil, singleArgument: Bool = false) async throws -> Result {
        let method = ICPMethod(
            canister: icpPrincipal,
            methodName: method,
            args: try encodeArguments(argument, singleArgument)
        )
        let response = try await callOrQuery(method, client, sender)
        let decoded: Result = try CandidDecoder().decode(response)
        return decoded
    }
}

public struct ICPFunctionNoArgsNoResult: CandidFunctionProtocol {
    public let canister: CandidPrincipal
    public let method: String
    public let query: Bool
    
    public init(_ canister: CandidPrincipal, _ method: String, _ query: Bool) {
        self.canister = canister
        self.method = method
        self.query = query
    }
    
    public func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws {
        let method = ICPMethod(canister: icpPrincipal, methodName: method)
        let _ = try await callOrQuery(method, client, sender)
    }
}

public struct ICPFunctionNoArgs<Result>: CandidFunctionProtocol where Result: Codable {
    public let canister: CandidPrincipal
    public let method: String
    public let query: Bool
    
    public init(_ canister: CandidPrincipal, _ method: String, _ query: Bool) {
        self.canister = canister
        self.method = method
        self.query = query
    }
    
    public func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(canister: icpPrincipal, methodName: method)
        let response = try await callOrQuery(method, client, sender)
        let decoded: Result = try CandidDecoder().decode(response)
        return decoded
    }
}

public struct ICPFunctionNoResult<Argument>: CandidFunctionProtocol where Argument: Codable {
    public let canister: CandidPrincipal
    public let method: String
    public let query: Bool
    
    public init(_ canister: CandidPrincipal, _ method: String, _ query: Bool) {
        self.canister = canister
        self.method = method
        self.query = query
    }
    
    public func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil, singleArgument: Bool = false) async throws {
        let method = ICPMethod(
            canister: icpPrincipal,
            methodName: method,
            args: try encodeArguments(argument, singleArgument)
        )
        let _ = try await callOrQuery(method, client, sender)
    }
}

fileprivate func encodeArguments<T>(_ arg: T, _ singleValue: Bool) throws -> [CandidValue] where T: Encodable {
    if singleValue {
        return [try CandidEncoder().encode(arg)]
    }
    if let tuple2 = arg as? CandidTuple2<Encodable, Encodable> {
        return [
            try CandidEncoder().encode(tuple2._0),
            try CandidEncoder().encode(tuple2._1),
        ]
    } else if let tuple3 = arg as? CandidTuple3<Encodable, Encodable, Encodable> {
        return [
            try CandidEncoder().encode(tuple3._0),
            try CandidEncoder().encode(tuple3._1),
            try CandidEncoder().encode(tuple3._2),
        ]
    } else if let tuple4 = arg as? CandidTuple4<Encodable, Encodable, Encodable, Encodable> {
        return [
            try CandidEncoder().encode(tuple4._0),
            try CandidEncoder().encode(tuple4._1),
            try CandidEncoder().encode(tuple4._2),
            try CandidEncoder().encode(tuple4._3),
        ]
    } else if let tuple5 = arg as? CandidTuple5<Encodable, Encodable, Encodable, Encodable, Encodable> {
        return [
            try CandidEncoder().encode(tuple5._0),
            try CandidEncoder().encode(tuple5._1),
            try CandidEncoder().encode(tuple5._2),
            try CandidEncoder().encode(tuple5._3),
            try CandidEncoder().encode(tuple5._4),
        ]
    } else if let tuple6 = arg as? CandidTuple6<Encodable, Encodable, Encodable, Encodable, Encodable, Encodable> {
        return [
            try CandidEncoder().encode(tuple6._0),
            try CandidEncoder().encode(tuple6._1),
            try CandidEncoder().encode(tuple6._2),
            try CandidEncoder().encode(tuple6._3),
            try CandidEncoder().encode(tuple6._4),
            try CandidEncoder().encode(tuple6._5),
        ]
    }
    return [try CandidEncoder().encode(arg)]
}

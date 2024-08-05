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

extension CandidFunctionProtocol {
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
    
    public func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(
            canister: icpPrincipal,
            methodName: method,
            args: try CandidEncoder().encode(argument)
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
    
    public func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws {
        let method = ICPMethod(
            canister: icpPrincipal,
            methodName: method,
            args: try CandidEncoder().encode(argument)
        )
        let _ = try await callOrQuery(method, client, sender)
    }
}

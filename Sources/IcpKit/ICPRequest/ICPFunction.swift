//
//  ICPFunction.swift
//
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation
import Candid

public class ICPFunction<Argument, Result, Query: StaticBool>: CandidFunctionProtocol {
    public let canister: CandidPrincipal
    public let methodName: String
    public var isQuery: Bool { Query.value }
    
    public required init(_ canister: CandidPrincipal, _ method: String) {
        self.canister = canister
        self.methodName = method
    }
}

public typealias ICPFunctionNoArgsNoResult<Query: StaticBool> = ICPFunction<Void, Void, Query>
public typealias ICPFunctionNoArgs<Result, Query: StaticBool> = ICPFunction<Void, Result, Query>
public typealias ICPFunctionNoResult<Argument, Query: StaticBool> = ICPFunction<Argument, Void, Query>

public typealias ICPQueryNoArgsNoResult = ICPQuery<Void, Void>
public typealias ICPQueryNoArgs<Result> = ICPQuery<Void, Result>
public typealias ICPQueryNoResult<Argument> = ICPQuery<Argument, Void>
public typealias ICPQuery<Argument, Result> = ICPFunction<Argument, Result, StaticTrue>

public typealias ICPCallNoArgsNoResult = ICPCall<Void, Void>
public typealias ICPCallNoArgs<Result> = ICPCall<Void, Result>
public typealias ICPCallNoResult<Argument> = ICPCall<Argument, Void>
public typealias ICPCall<Argument, Result> = ICPFunction<Argument, Result, StaticFalse>

public extension ICPQuery {
    func toCall() -> ICPCall<Argument, Result> { ICPCall(canister, methodName) }
}

public extension ICPFunction where Argument: Encodable, Result: Decodable {
    func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(
            canister: canister,
            methodName: methodName,
            args: try encodeArguments(argument)
        )
        let response = try await callOrQuery(method, client, sender)
        let decoded: Result = try CandidDecoder().decode(response)
        return decoded
    }
}

public extension ICPFunctionNoResult where Argument: Encodable {
    func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws {
        let method = ICPMethod(
            canister: canister,
            methodName: methodName,
            args: try encodeArguments(argument)
        )
        let _ = try await callOrQuery(method, client, sender)
    }
}

public extension ICPFunctionNoArgs where Result: Decodable {
    func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(canister: canister, methodName: methodName)
        let response = try await callOrQuery(method, client, sender)
        let decoded: Result = try CandidDecoder().decode(response)
        return decoded
    }
}

public extension ICPFunctionNoArgsNoResult {
    func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws {
        let method = ICPMethod(canister: canister, methodName: methodName)
        let _ = try await callOrQuery(method, client, sender)
    }
}

fileprivate extension CandidFunctionProtocol {
    func callOrQuery(_ method: ICPMethod, _ client: ICPRequestClient, _ sender: ICPSigningPrincipal?) async throws -> CandidValue {
        if isQuery {
            return try await client.query(method, effectiveCanister: canister, sender: sender)
        } else {
            return try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
        }
    }
    
    func encodeArguments<T>(_ arg: T) throws -> [CandidValue] where T: Encodable {
        if let multiArgs = arg as? any ICPFunctionArgs {
            return try multiArgs.map { try CandidEncoder().encode($0) }
        } else {
            return [try CandidEncoder().encode(arg)]
        }
    }
}

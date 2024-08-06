//
//  ICPFunction.swift
//
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation
import Candid

public extension CandidFunctionProtocol {
    init(_ canister: ICPPrincipal, _ method: String) {
        self.init(CandidPrincipal(canister.bytes), method)
    }
    
    var icpPrincipal: ICPPrincipal { ICPPrincipal(canister) }
}

public class ICPFunction<Argument, Result, Query: StaticBool>: CandidFunctionProtocol {
    public let canister: CandidPrincipal
    public let method: String
    public var query: Bool { Query.value }
    
    public required init(_ canister: CandidPrincipal, _ method: String) {
        self.canister = canister
        self.method = method
    }
}

public typealias ICPFunctionNoArgsNoResult<Query: StaticBool> = ICPFunction<Void, Void, Query>
public typealias ICPFunctionNoArgs<Result, Query: StaticBool> = ICPFunction<Void, Result, Query>
public typealias ICPFunctionNoResult<Argument, Query: StaticBool> = ICPFunction<Argument, Void, Query>

public typealias ICPQueryNoArgsNoResult = ICPFunctionNoArgsNoResult<StaticTrue>
public typealias ICPQueryNoArgs<Result> = ICPFunctionNoArgs<Result, StaticTrue>
public typealias ICPQueryNoResult<Argument> = ICPFunctionNoResult<Argument, StaticTrue>
public typealias ICPQuery<Argument, Result> = ICPFunction<Argument, Result, StaticTrue>

public typealias ICPCallNoArgsNoResult = ICPFunctionNoArgsNoResult<StaticFalse>
public typealias ICPCallNoArgs<Result> = ICPFunctionNoArgs<Result, StaticFalse>
public typealias ICPCallNoResult<Argument> = ICPFunctionNoResult<Argument, StaticFalse>
public typealias ICPCall<Argument, Result> = ICPFunction<Argument, Result, StaticFalse>

public extension ICPFunction where Argument: Encodable, Result: Decodable {
    func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(
            canister: icpPrincipal,
            methodName: method,
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
            canister: icpPrincipal,
            methodName: method,
            args: try encodeArguments(argument)
        )
        let _ = try await callOrQuery(method, client, sender)
    }
}

public extension ICPFunctionNoArgs where Result: Decodable {
    func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(canister: icpPrincipal, methodName: method)
        let response = try await callOrQuery(method, client, sender)
        let decoded: Result = try CandidDecoder().decode(response)
        return decoded
    }
}

public extension ICPFunctionNoArgsNoResult {
    func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws {
        let method = ICPMethod(canister: icpPrincipal, methodName: method)
        let _ = try await callOrQuery(method, client, sender)
    }
}

fileprivate extension CandidFunctionProtocol {
    func callOrQuery(_ method: ICPMethod, _ client: ICPRequestClient, _ sender: ICPSigningPrincipal?) async throws -> CandidValue {
        if query {
            return try await client.query(method, effectiveCanister: icpPrincipal, sender: sender)
        } else {
            return try await client.callAndPoll(method, effectiveCanister: icpPrincipal, sender: sender)
        }
    }
    
    // TODO: Is this necessary? If yes, this should be injected at init
    var splitArguments: Bool { false }
    func encodeArguments<T>(_ arg: T) throws -> [CandidValue] where T: Encodable {
        guard splitArguments else {
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
}

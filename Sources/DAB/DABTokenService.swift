//
//  DABTokenService.swift
//
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation
import IcpKit
import BigInt

public class DABTokenService {
    private let client: ICPRequestClient
    private let service: DABTokens.Service
    
    private var cachedTokens: [ICPToken]?
    
    public init(_ client: ICPRequestClient = ICPRequestClient()) {
        self.client = client
        service = DABTokens.Service(DABService.tokenRegistry, client: client)
    }
    
    public func tokenStandard(for canister: ICPPrincipal) async throws -> ICPTokenStandard? {
        try await allTokens().first(where: { $0.canister == canister })?.standard
    }
    
    public func `actor`(for standard: ICPTokenStandard, _ canister: ICPPrincipal) -> ICPTokenActor? {
        ICPTokenActorFactory.actor(for: standard, canister, client)
    }
    
    public func `actor`(for canister: ICPPrincipal) async throws -> ICPTokenActor? {
        guard let standard = try await tokenStandard(for: canister) else { return nil }
        return ICPTokenActorFactory.actor(for: standard, canister, client)
    }
    
    public func `actor`(for token: ICPToken) -> ICPTokenActor? {
        ICPTokenActorFactory.actor(for: token, client)
    }
    
    public func allTokens() async throws -> [ICPToken] {
        if let cachedTokens = cachedTokens { return cachedTokens }
        let dabTokens = try await service.get_all()
        cachedTokens = try dabTokens.map(ICPToken.init)
        return cachedTokens!
    }
    
    public func balance(of user: ICPAccount) async throws -> [ICPTokenBalance] {
        let tokens = try await allTokens()
        let holdings = await withTaskGroup(of: ICPTokenBalance?.self) { group in
            for token in tokens {
                group.addTask {
                    let actor = ICPTokenActorFactory.actor(for: token.standard, token.canister, self.client)
                    guard let actor = actor else { return nil }
                    guard let balance = try? await actor.balance(of: user),
                          balance > .zero else { return nil }
                    return ICPTokenBalance(token: token, balance: balance)
                }
            }
            var holdings: [ICPTokenBalance] = []
            for await holding in group.compactMap({ $0 }) {
                holdings.append(holding)
            }
            return holdings
        }
        return holdings
    }
}

private extension ICPToken {
    init(_ dabToken: DABTokens.token) throws {
        guard let standard = ICPTokenStandard(try dabToken.details["standard"]?.textValue),
              let decimals = try dabToken.details["decimals"]?.u64Value,
              let symbol = try dabToken.details["symbol"]?.textValue,
              let totalSupply = try dabToken.details["total_supply"]?.u64Value,
              let verified = try dabToken.details["verified"]?.boolValue else {
            throw DABTokens.detail_value.TypeError.invalidType
        }
        self.standard = standard
        self.canister = dabToken.principal_id
        self.name = dabToken.name
        self.decimals = UInt(decimals)
        self.symbol = symbol
        self.description = dabToken.description
        self.totalSupply = BigUInt(totalSupply)
        self.verified = verified
        self.logo = URL(string: dabToken.thumbnail)
        self.website = URL(string: dabToken.frontend ?? "")
    }
}

private typealias DABTokenDetail = CandidTuple2<String, DABTokens.detail_value>
private extension [DABTokenDetail] {
    subscript (_ key: String) -> DABTokens.detail_value? {
        first(where: { $0._0 == key})?._1
    }
}

private extension DABTokens.detail_value {
    enum TypeError: Error { case invalidType }
    var textValue: String {
        get throws {
            guard case .Text(let text) = self else {
                throw TypeError.invalidType
            }
            return text
        }
    }
    
    var u64Value: UInt64 {
        get throws {
            guard case .U64(let u64) = self else {
                throw TypeError.invalidType
            }
            return u64
        }
    }
    
    var boolValue: Bool {
        get throws {
            if case .True = self { return true }
            else if case .False = self { return false }
            throw TypeError.invalidType
        }
    }
}

private extension ICPTokenStandard {
    init?(_ string: String?) {
        guard let string = string else { return nil }
        self.init(rawValue: string)
    }
}

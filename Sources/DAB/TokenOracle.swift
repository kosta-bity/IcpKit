//
//  TokenOracle.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 08.10.2024.
//

import Foundation
import IcpKit

public final class TokenOracle: @unchecked Sendable {
    private let client: ICPRequestClient
    private let service: ICRC1Oracle.Service
    private let transactionProvider: ICPTransactionProvider
    
    private var cachedCanisters: [ICRC1Oracle.ICRC1]?

    public init(_ client: ICPRequestClient = ICPRequestClient()) {
        self.client = client
        transactionProvider = ICPTransactionProvider(client)
        service = ICRC1Oracle.Service(DABService.icrc1Oracle, client: client)
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
    
    public func token(for canister: ICPPrincipal) -> ICPToken? {
        try? cachedCanisters?.first { $0.ledger == canister.string }.map(ICPToken.init)
    }
    
    public func allTokens() async throws -> [ICPToken] {
        if let cachedCanisters = cachedCanisters {
            return cachedCanisters.compactMap { try? ICPToken($0) }
        }
        cachedCanisters = try await fetchAllIcrc1Canisters()
        return cachedCanisters!.compactMap { try? ICPToken($0) }
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
    
    public func transactions(of user: ICPAccount, for token: ICPToken) async throws -> [ICPTokenTransaction] {
        return try await transactions(of: user, for: token.canister)
    }
    
    public func transactions(of user: ICPAccount, for tokenCanister: ICPPrincipal) async throws -> [ICPTokenTransaction] {
        guard let icrc1 = cachedCanisters?.first(where: { $0.ledger == tokenCanister.string }),
              let token = try? ICPToken(icrc1) else {
            throw DABTokenServiceError.tokenNotFound
        }
        
        let provider: ICPTransactionProviderProtocol
        if icrc1.category == .Native {
             provider = ICPIndexTransactionProvider(client: service.client, icpToken: token)
            
        } else if let index = icrc1.index, let indexCanister = try? ICPPrincipal(index) {
            provider = ICPICRC1IndexTransactionProvider(client: service.client, token: token, indexCanister: indexCanister)
            
        } else {
            return []
        }
        let transactions = try await provider.transactions(of: user)
        return transactions
    }
    
    public func explorerUrl(tokenCanister: ICPPrincipal, transactionIndex: String) async throws -> URL? {
        try await transactionProvider.explorerUrl(tokenCanister: tokenCanister, transactionIndex: transactionIndex)
    }
}

extension ICRC1Oracle.ICRC1: @unchecked Sendable {}
extension ICRC1Oracle.Service: @unchecked Sendable {}

private extension TokenOracle {
    func fetchAllIcrc1Canisters() async throws -> [ICRC1Oracle.ICRC1] {
        let pageSize: UInt64 = 10
        let canisterCount = try await service.count_icrc1_canisters()
        let nPages = canisterCount / pageSize + 1
        let canisters = await withTaskGroup(of: [ICRC1Oracle.ICRC1].self) { [weak self] group in
            let service = self?.service
            for i in 0..<nPages {
                group.addTask {
                    let startAt = i * pageSize
                    let canisters = try? await service?.get_icrc1_paginated(startAt, pageSize)
                    return canisters ?? []
                }
            }
            var canisters: [ICRC1Oracle.ICRC1] = []
            while let finished = await group.next() {
                canisters.append(contentsOf: finished)
            }
            return canisters
        }
        return canisters
    }
}

private extension ICPToken {
    init(_ icrc1: ICRC1Oracle.ICRC1) throws {
        name = icrc1.name
        decimals = UInt(icrc1.decimals)
        symbol = icrc1.symbol
        logo = icrc1.logo == nil ? nil : URL(string: icrc1.logo!)
        canister = try ICPPrincipal(icrc1.ledger)
        standard = icrc1.category.standard
        
        // rename to spam
        verified = icrc1.category.verified
    }
}

private extension ICRC1Oracle.Category {
    var verified: Bool {
        switch self {
        case .Sns, .Native, .Known, .ChainFusion, .Community, .ChainFusionTestnet:
            return true
        case .Spam:
            return false
        }
    }
    
    var standard: ICPTokenStandard {
        switch self {
        case .Sns, .Spam, .Known, .ChainFusionTestnet, .ChainFusion, .Community:
            return .icrc1
        case .Native:
            return .icp
        }
    }
}

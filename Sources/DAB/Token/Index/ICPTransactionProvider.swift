//
//  ICPTransactionProvider.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 25.09.2024.
//

import Foundation
import IcpKit
import BigInt

class ICPTransactionProvider {
    let service: NNS_SNS_W.Service
    private var cachedSnses: [NNS_SNS_W.DeployedSns]?
    
    init(_ client: ICPRequestClient) {
        service = NNS_SNS_W.Service(ICPSystemCanisters.nns_sns_w, client: client)
    }
 
    func transactions(of user: ICPAccount, tokenCanister: ICPPrincipal) async throws -> [ICPTokenTransaction] {
        guard let provider = try await transactionProvider(for: tokenCanister) else {
            return []
        }
        return try await provider.transactions(of: user)
    }
    
    private func deployedSnses() async throws -> [NNS_SNS_W.DeployedSns] {
        if let cachedSnses = cachedSnses { return cachedSnses }
        cachedSnses = try await service.list_deployed_snses().instances
        return cachedSnses!
    }
    
    private func findIndexCanisterInSNS(tokenCanister: ICPPrincipal) async throws -> ICPPrincipal? {
        let deployed = try await deployedSnses()
        let sns = deployed.first { $0.contains(tokenCanister) }
        return sns?.index_canister_id
    }
    
    private func transactionProvider(for tokenCanister: ICPPrincipal) async throws -> ICPTransactionProviderProtocol? {
        // TODO: Support DIP20 tokens
        if tokenCanister == ICPSystemCanisters.ledger {
            return ICPIndexTransactionProvider(client: service.client)
        }
        guard let index = try await findIndexCanisterInSNS(tokenCanister: tokenCanister) else {
            return nil
        }
        return ICPICRC1IndexTransactionProvider(client: service.client, tokenCanister: tokenCanister, indexCanister: index)
    }
}

private extension NNS_SNS_W.DeployedSns {
    func contains(_ canister: ICPPrincipal) -> Bool {
        governance_canister_id == canister ||
        index_canister_id == canister ||
        ledger_canister_id == canister ||
        root_canister_id == canister ||
        swap_canister_id == canister
    }
}


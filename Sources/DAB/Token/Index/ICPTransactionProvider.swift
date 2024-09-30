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
 
    func transactions(of user: ICPAccount, token: ICPToken) async throws -> [ICPTokenTransaction] {
        guard let provider = try await transactionProvider(for: token) else {
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
    
    private func transactionProvider(for token: ICPToken) async throws -> ICPTransactionProviderProtocol? {
        // TODO: Support DIP20 tokens
        if token.canister == ICPSystemCanisters.ledger {
            return ICPIndexTransactionProvider(client: service.client, icpToken: token)
        }
        guard let index = try await findIndexCanisterInSNS(tokenCanister: token.canister) else {
            return nil
        }
        return ICPICRC1IndexTransactionProvider(client: service.client, token: token, indexCanister: index)
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


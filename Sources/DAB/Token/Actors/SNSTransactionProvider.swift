//
//  File.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 25.09.2024.
//

import Foundation
import IcpKit

class SNSTransactionPRovider {
    static let NNS_SNS_W_Canister: ICPPrincipal = "qaa6y-5yaaa-aaaaa-aaafa-cai"
    
    let tokenCanister: ICPPrincipal
    let service: NNS_SNS_W.Service
    
    init(_ tokenCanister: ICPPrincipal, _ client: ICPRequestClient) {
        self.tokenCanister = tokenCanister
        service = NNS_SNS_W.Service(Self.NNS_SNS_W_Canister, client: client)
    }
 
    func findIndexCanister() async throws -> ICPPrincipal? {
        let deployed = try await service.list_deployed_snses()
        let sns = deployed.first(containing: tokenCanister)
        return sns?.index_canister_id
    }
    
    func transactions(of user: ICPAccount) async throws -> [ICPTokenTransaction] {
        guard let index = try await findIndexCanister() else {
            return []
        }
        let indexService = Index.Service(index, client: service.client)
        let transactions = try await indexService.get_account_transactions(Index.GetAccountTransactionsArgs(
            max_results: 1000,
            start: nil,
            account: Index.Account(owner: user.principal, subaccount: user.subAccountId)
        )).get()
        return transactions.transactions.compactMap { try? ICPTokenTransaction($0, tokenCanister) }
    }
}

private extension NNS_SNS_W.ListDeployedSnsesResponse {
    func first(containing canister: ICPPrincipal) -> NNS_SNS_W.DeployedSns? {
        instances.first { $0.contains(canister) }
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

private extension Index.GetTransactionsResult {
    func get() throws -> Index.GetTransactions {
        switch self {
        case .Ok(let transactions): return transactions
        case .Err(let error): throw error
        }
    }
}

extension Index.GetTransactionsErr: Error {}

private extension ICPTokenTransaction {
    init?(_ transaction: Index.TransactionWithId, _ tokenCanister: ICPPrincipal) throws {
        if let burn = transaction.transaction.burn {
            operation = .burn(from: try ICPAccount(burn.from))
            amount = burn.amount
            fee = .zero
            spender = try burn.spender.map(ICPAccount.init)
            created = burn.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            
        } else if let approve = transaction.transaction.approve {
            operation = .approve(
                from: try ICPAccount(approve.from),
                expectedAllowance: approve.expected_allowance,
                expires: approve.expires_at.map { Date(nanoSecondsSince1970: $0) }
            )
            amount = approve.amount
            fee = approve.fee ?? .zero
            spender = try ICPAccount(approve.spender)
            created = approve.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            
        } else if let transfer = transaction.transaction.transfer {
            operation = .transfer(from: try ICPAccount(transfer.from), to: try ICPAccount(transfer.to))
            amount = transfer.amount
            fee = transfer.fee ?? .zero
            spender = try transfer.spender.map(ICPAccount.init)
            created = transfer.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            
        } else if let mint = transaction.transaction.mint {
            operation = .mint(to: try ICPAccount(mint.to))
            amount = mint.amount
            fee = .zero
            spender = nil
            created = mint.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            
        } else {
            return nil
        }
        
        timeStamp = Date(nanoSecondsSince1970: transaction.transaction.timestamp)
        index = transaction.id
        self.tokenCanister = tokenCanister
        memo = nil
    }
}

private extension ICPAccount {
    init(_ account: Index.Account) throws {
        try self.init(principal: account.owner, subAccountId: account.subaccount ?? ICPAccount.defaultSubAccountId)
    }
}

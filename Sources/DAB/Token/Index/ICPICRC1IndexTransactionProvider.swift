//
//  ICPICRC1IndexTransactionProvider.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 26.09.2024.
//
import Foundation
import IcpKit

class ICPICRC1IndexTransactionProvider: ICPTransactionProviderProtocol {
    let client: ICPRequestClient
    let token: ICPToken
    let indexCanister: ICPPrincipal
    
    init(client: ICPRequestClient, token: ICPToken, indexCanister: ICPPrincipal) {
        self.client = client
        self.token = token
        self.indexCanister = indexCanister
    }
    
    func transactions(of user: IcpKit.ICPAccount) async throws -> [ICPTokenTransaction] {
        let indexService = Index.Service(indexCanister, client: client)
        let transactions = try await indexService.get_account_transactions(Index.GetAccountTransactionsArgs(
            max_results: 1000,
            start: nil,
            account: Index.Account(owner: user.principal, subaccount: user.subAccountId)
        )).get()
        return transactions.transactions.compactMap { try? ICPTokenTransaction($0, token) }
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

extension Index.GetTransactionsErr: Error, @unchecked Sendable {}

private extension ICPTokenTransaction {
    init?(_ transaction: Index.TransactionWithId, _ token: ICPToken) throws {
        if let burn = transaction.transaction.burn {
            operation = .burn(from: try ICPTokenTransaction.Destination(burn.from))
            amount = burn.amount
            fee = .zero
            spender = try burn.spender.map(ICPTokenTransaction.Destination.init)
            created = burn.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            icrc1Memo = burn.memo
            
        } else if let approve = transaction.transaction.approve {
            operation = .approve(
                from: try ICPTokenTransaction.Destination(approve.from),
                expectedAllowance: approve.expected_allowance,
                expires: approve.expires_at.map { Date(nanoSecondsSince1970: $0) }
            )
            amount = approve.amount
            fee = approve.fee ?? .zero
            spender = try ICPTokenTransaction.Destination(approve.spender)
            created = approve.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            icrc1Memo = approve.memo
            
        } else if let transfer = transaction.transaction.transfer {
            operation = .transfer(from: try ICPTokenTransaction.Destination(transfer.from), to: try ICPTokenTransaction.Destination(transfer.to))
            amount = transfer.amount
            fee = transfer.fee ?? .zero
            spender = try transfer.spender.map(ICPTokenTransaction.Destination.init)
            created = transfer.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            icrc1Memo = transfer.memo
            
        } else if let mint = transaction.transaction.mint {
            operation = .mint(to: try ICPTokenTransaction.Destination(mint.to))
            amount = mint.amount
            fee = .zero
            spender = nil
            created = mint.created_at_time.map { Date(nanoSecondsSince1970: $0) }
            icrc1Memo = mint.memo
            
        } else {
            return nil
        }
        
        timeStamp = Date(nanoSecondsSince1970: transaction.transaction.timestamp)
        index = transaction.id
        self.token = token
        memo = nil
    }
}

private extension ICPAccount {
    init(_ account: Index.Account) throws {
        try self.init(principal: account.owner, subAccountId: account.subaccount ?? ICPAccount.defaultSubAccountId)
    }
}

private extension ICPTokenTransaction.Destination {
    init(_ account: Index.Account) throws {
        self = .account(try ICPAccount(account))
    }
}

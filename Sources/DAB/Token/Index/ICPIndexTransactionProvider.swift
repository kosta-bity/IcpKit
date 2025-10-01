//
//  ICPIndexTransactionProvider.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 26.09.2024.
//
import IcpKit
import BigInt
import Foundation

class ICPIndexTransactionProvider: ICPTransactionProviderProtocol {
    let client: ICPRequestClient
    let icpToken: ICPToken
    
    init(client: ICPRequestClient, icpToken: ICPToken) {
        self.icpToken = icpToken
        self.client = client
    }
    
    func transactions(of user: IcpKit.ICPAccount) async throws -> [ICPTokenTransaction] {
        let indexService = ICPIndex.Service(ICPSystemCanisters.index, client: client)
        let transactions = try await indexService.get_account_transactions(ICPIndex.GetAccountTransactionsArgs(
            max_results: 1000,
            start: nil,
            account: ICPIndex.Account(owner: user.principal, subaccount: user.subAccountId)
        )).get()
        return transactions.transactions.map { ICPTokenTransaction($0, icpToken) }
    }
}

private extension ICPIndex.GetAccountIdentifierTransactionsResult {
    func get() throws -> ICPIndex.GetAccountIdentifierTransactionsResponse {
        switch self {
        case .Ok(let transactions): return transactions
        case .Err(let error): throw error
        }
    }
}

private extension ICPTokenTransaction {
    init(_ transaction: ICPIndex.TransactionWithId, _ token: ICPToken) {
        switch transaction.transaction.operation {
        case .Burn(let from, let amount, let spender):
            operation = .burn(from: .accountId(from))
            self.amount = BigUInt(amount.e8s)
            fee = .zero
            self.spender = spender.map { .accountId($0) }
            
        case .Approve(let fee, let from, let allowance, let expectedAllowance, let expiresAt, let spender):
            operation = .approve(
                from: .accountId(from),
                expectedAllowance: expectedAllowance.map { BigUInt($0.e8s) },
                expires: expiresAt.map { Date(nanoSecondsSince1970: $0.timestamp_nanos) }
            )
            amount = BigUInt(allowance.e8s)
            self.fee = BigUInt(fee.e8s)
            self.spender = .accountId(spender)
            
        case .Transfer(let to, let fee, let from, let amount, let spender):
            operation = .transfer(from: .accountId(from), to: .accountId(to))
            self.amount = BigUInt(amount.e8s)
            self.fee = BigUInt(fee.e8s)
            self.spender = spender.map { .accountId($0) }
            
        case .Mint(let to, let amount):
            operation = .mint(to: .accountId(to))
            self.amount = BigUInt(amount.e8s)
            fee = .zero
            spender = nil
        }
        
        timeStamp = transaction.transaction.timestamp.map { Date(nanoSecondsSince1970: $0.timestamp_nanos) }
        created = transaction.transaction.created_at_time.map { Date(nanoSecondsSince1970: $0.timestamp_nanos) }
        index = BigUInt(transaction.id)
        self.token = token
        icrc1Memo = transaction.transaction.icrc1_memo
        memo = transaction.transaction.memo
    }
}

extension ICPIndex.GetAccountIdentifierTransactionsError: Error, @unchecked Sendable {}

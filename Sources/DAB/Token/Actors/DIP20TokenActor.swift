//
//  DIP20TokenActor.swift
//
//
//  Created by Konstantinos Gaitanis on 06.09.24.
//

import Foundation
import IcpKit
import BigInt

class DIP20TokenActor: ICPTokenActor {
    let standard: ICPTokenStandard = .dip20
    let service: DIP20.Service
    
    required init(_ canister: ICPPrincipal, _ client: ICPRequestClient) {
        service = DIP20.Service(canister, client: client)
    }
    
    func fee() async throws -> BigUInt {
        try await metaData().fee
    }
    
    func metaData() async throws -> ICPTokenMetadata {
        let metadata = try await service.getMetadata()
        return ICPTokenMetadata(metadata)
    }
    
    func balance(_ principal: ICPPrincipal) async throws -> BigUInt {
        let balance = try await service.balanceOf(who: principal)
        return balance
    }
    
    func transfer(_ args: ICPTokenTransferArgs) async throws -> ICPTokenTransferResponse {
        let blockIndex = try await service.transfer(to: args.to.principal, value: args.amount, sender: args.sender).get()
        return .height(blockIndex)
    }
    
    func approve(_ args: ICPTokenApproveArgs) async throws {
        let _ = try await service.approve(spender: args.spender, value: args.amount, sender: args.sender).get()
    }
    
    func transactions(of user: ICPPrincipal) async throws -> [ICPTokenTransaction] {
        do {
            let transactions = try await service.getUserTransactions(who: user, start: 0, limit: 10000)
            let icpTransactions = transactions.map { ICPTokenTransaction($0, service.canister) }
            return icpTransactions
        } catch {
            // Probably means that method is not supported by this canister
            return []
        }
    }
}

private extension ICPTokenMetadata {
    init(_ metadata: DIP20.Metadata) {
        name = metadata.name
        symbol = metadata.symbol
        decimals = Int(metadata.decimals)
        totalSupply = metadata.totalSupply
        logo = URL(string: metadata.logo)
        fee = metadata.fee
    }
}

private extension DIP20.TxReceipt {
    func get() throws -> BigUInt {
        switch self {
        case .Ok(let blockIndex): return blockIndex
        case .Err(let error): throw error
        }
    }
}

extension DIP20.TxError: Error {}

private extension ICPTokenTransaction {
    init(_ tx: DIP20.TxRecord, _ canister: ICPPrincipal) {
        from = tx.from
        to = tx.to
        amount = tx.amount
        fee = tx.fee
        timeStamp = Date(nanoSecondsSince1970: tx.timestamp.timestamp_nanos)
        caller = tx.caller
        index = tx.index
        operation = Operation(tx.op)
        status = Status(tx.status)
        self.canister = canister
    }
}

private extension ICPTokenTransaction.Operation {
    init(_ operation: DIP20.Operation) {
        switch operation {
        case .transferFrom: self = .transferFrom
        case .mint: self = .mint
        case .approve: self = .approve
        case .transfer: self = .transfer
        }
    }
}

private extension ICPTokenTransaction.Status {
    init(_ status: DIP20.TransactionStatus) {
        switch status {
        case .failed: self = .failed
        case .succeeded: self = .succeeded
        }
    }
}

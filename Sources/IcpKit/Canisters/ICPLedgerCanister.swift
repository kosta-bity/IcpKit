//
//  ICPLedgerCanister.swift
//
//  Created by Konstantinos Gaitanis on 26.04.23.
//

import Foundation
import BigInt
import Candid

public enum ICPLedgerCanisterError: Error {
    case invalidAddress
    case invalidResponse
    case blockNotFound
    case invalidBlock
    case transferFailed(ICPLedgerCanisterTransferError)
}

public enum ICPLedgerCanisterTransferError: Error {
    case txTooOld(allowedWindowNanos: UInt64)
    case badFee(expectedFee: UInt64)
    case txDuplicate(duplicateOf: UInt64)
    case txCreatedInFuture
    case insufficientFunds(balance: UInt64)
}

public enum ICPLedgerCanister {
    private static func service(_ client: ICPRequestClient) -> LedgerCanister.Service { LedgerCanister.Service(ICPSystemCanisters.ledger, client: client) }
    /// The fixed fee to be applied on all ICP transactions
    public static let defaultFee: UInt64 = 10_000 // 0.0001 ICP
    
    
    /// Queries the Ledger Canister for the ICP balance of the given `ICPAccount`
    ///
    /// - Parameters:
    ///   - account: The account
    ///   - client: The client to use
    /// - Returns: The account balance in ICP (8 digits precision)
    public static func accountBalance(of account: ICPAccount, _ client: ICPRequestClient) async throws -> UInt64 {
        let balanceArgs = try await service(client).account_balance(.init(account: account.accountId))
        return balanceArgs.e8s
    }
    
    /// Sends a transaction request to the Ledger Canister and waits for its response
    /// - Parameters:
    ///   - sendingAccount: The `from` account
    ///   - receivingAddress: The `to` account
    ///   - amount: How much to the `to` account will receive. The sender will send this amount + the fee
    ///   - signingPrincipal: The signing principal
    ///   - fee: The fee to use. Defaults to the standard ICP fee of 0.0001 ICP
    ///   - memo: An optional memo to attach to the transaction
    ///   - client: The client to use
    /// - Returns: the blockIndex of the transaction
    public static func transfer(from sendingAccount: ICPAccount,
                         to receivingAddress: String,
                         amount: UInt64,
                         signingPrincipal: ICPSigningPrincipal,
                         fee: UInt64 = Self.defaultFee,
                         memo: UInt64 = 0,
                         _ client: ICPRequestClient) async throws -> UInt64 {
        guard ICPCryptography.validateAccountId(receivingAddress) else {
            throw ICPLedgerCanisterError.invalidAddress
        }
        let args = LedgerCanister.TransferArgs(
            to: Data.fromHex(receivingAddress)!,
            fee: .init(e8s: fee),
            memo: memo,
            from_subaccount: sendingAccount.subAccountId,
            created_at_time: .now,
            amount: .init(e8s: amount)
        )
        let response = try await service(client).transfer(args, sender: signingPrincipal)
        switch response {
        case .Err(let transferError):
            throw ICPLedgerCanisterError.transferFailed(ICPLedgerCanisterTransferError(transferError))
        case .Ok(let blockIndex):
            return blockIndex
        }
    }
    
    /// Queries the Ledger Canister for information about a certain block.
    ///
    /// If the block is archived, this will also perform the corresponding Archive Query to fetch it
    /// seamlessly.
    ///
    /// - Parameters:
    ///   - index: The block index to query
    ///   - client: The client to use
    /// - Returns: The `ICPBlock` instance corresponding to the block index
    public static func queryBlock(index: UInt64, _ client: ICPRequestClient) async throws -> ICPBlock {
        let response = try await service(client).query_blocks(.init(start: index, length: 1))
        if let block = response.blocks.first {
            return try ICPBlock(block)
        }
        if let archivedBlock = response.archived_blocks.first {
            let archiveResponse = try await archivedBlock.callback.callMethod(.init(start: archivedBlock.start, length: archivedBlock.length), client)
            switch archiveResponse {
            case .Ok(let blocks):
                guard let block = blocks.blocks.first else {
                    throw ICPLedgerCanisterError.blockNotFound
                }
                return try ICPBlock(block)
            case .Err:
                throw ICPLedgerCanisterError.blockNotFound
            }
        }
        throw ICPLedgerCanisterError.blockNotFound
    }
}

private extension ICPBlock {
    init(_ ledgerBlock: LedgerCanister.Block) throws {
        guard let parentHash = ledgerBlock.parent_hash,
              let operation = ledgerBlock.transaction.operation  else {
            throw ICPLedgerCanisterError.invalidBlock
        }
        self.parentHash = parentHash
        self.timestamp = ledgerBlock.timestamp.timestamp_nanos
        self.transaction = ICPBlock.Transaction(
            memo: ledgerBlock.transaction.memo,
            createdNanos: ledgerBlock.transaction.created_at_time.timestamp_nanos,
            operation: .init(operation)
        )
    }
}

private extension ICPBlock.Transaction.Operation {
    init(_ operation: LedgerCanister.Operation) {
        switch operation {
        case .Burn(let from, let amount): self = .burn(from: from, amount: amount.e8s)
        case .Mint(let to, let amount): self = .mint(to: to, amount: amount.e8s)
        case .Transfer(let to, let fee, let from, let amount): self = .transfer(from: from, to: to, amount: amount.e8s, fee: fee.e8s)
        }
    }
}

private extension ICPLedgerCanisterTransferError {
    init(_ ledgerError: LedgerCanister.TransferError) {
        switch ledgerError {
        case .TxTooOld(allowed_window_nanos: let allowed_window_nanos):
            self = .txTooOld(allowedWindowNanos: allowed_window_nanos)
        case .BadFee(expected_fee: let expected_fee):
            self = .badFee(expectedFee: expected_fee.e8s)
        case .TxDuplicate(duplicate_of: let duplicate_of):
            self = .txDuplicate(duplicateOf: duplicate_of)
        case .TxCreatedInFuture:
            self = .txCreatedInFuture
        case .InsufficientFunds(balance: let balance):
            self = .insufficientFunds(balance: balance.e8s)
        }
    }
}

private extension LedgerCanister.TimeStamp {
    static var now: LedgerCanister.TimeStamp {
        return LedgerCanister.TimeStamp(timestamp_nanos: UInt64(Date.now.timeIntervalSince1970) * 1_000_000_000)
    }
}

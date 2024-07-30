//
//  ICPLedgerCanister.swift
//  Runner
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
    case transferFailed(ICPTransferError)
}

public enum ICPTransferError: Error {
    case badFee(expectedFee: UInt64)
    case insufficientFunds(balance: UInt64)
    case transactionTooOld(allowedWindowNanoSeconds: UInt64)
    case transactionCreatedInFuture
    case transactionDuplicate(blockIndex: UInt64)
    case couldNotFindPostedTransaction
}

public enum ICPLedgerCanister {
    /// The fixed fee to be applied on all ICP transactions
    public static let defaultFee: UInt64 = 10_000 // 0.0001 ICP
    
    
    /// Queries the Ledger Canister for the ICP balance of the given `ICPAccount`
    ///
    /// This can be performed in different ways depending on the required certification level.
    ///
    /// - Parameters:
    ///   - certification: The certification level
    ///   - account: The account
    ///   - client: The client to use
    /// - Returns: The account balance in ICP (8 digits precision)
    public static func accountBalance(_ certification: ICPRequestCertification = .certified, of account: ICPAccount, _ client: ICPRequestClient) async throws -> UInt64 {
        let method = accountBalanceMethod(account)
        let response = try await client.query(certification, method, effectiveCanister: ICPSystemCanisters.ledger)
        return try parseAccountBalanceResponse(response)
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
                         memo: UInt64? = nil,
                         _ client: ICPRequestClient) async throws -> UInt64 {
        guard ICPCryptography.validateAccountId(receivingAddress) else {
            throw ICPLedgerCanisterError.invalidAddress
        }
        let method = transferMethod(from: sendingAccount, to: receivingAddress, amount: amount, fee: fee, memo: memo)
        let response = try await client.callAndPoll(method, effectiveCanister: ICPSystemCanisters.ledger, sender: signingPrincipal)
        return try parseTranserResponse(response)
    }
    
    /// Queries the Ledger Canister for information about a certain block.
    ///
    /// If the block is archived, this will also perform the corresponding Archive Query to fetch it
    /// seamlessly.
    ///
    /// - Parameters:
    ///   - certification: The certification level
    ///   - index: The block index to query
    ///   - client: The client to use
    /// - Returns: The `ICPBlock` instance corresponding to the block index
    public static func queryBlock(_ certification: ICPRequestCertification = .certified, index: UInt64, _ client: ICPRequestClient) async throws -> ICPBlock {
        let method = queryBlocksMethod(startAt: index, length: 1)
        let response = try await client.query(certification, method, effectiveCanister: ICPSystemCanisters.ledger)
        let queryBlockResponse = try QueryBlockResponse.from(response)
        
        if let block = queryBlockResponse.blocks.first {
            return block
        }
        
        if let archivedBlock = queryBlockResponse.archivedBlocks.first {
            guard let method = archivedBlock.callback.method else {
                throw ICPLedgerCanisterError.invalidResponse
            }
            let icpBlocks = try await queryArchivedBlock(certification, method, start: archivedBlock.start, length: archivedBlock.length, client)
            guard let icpBlock = icpBlocks.first else {
                throw ICPLedgerCanisterError.blockNotFound
            }
            return icpBlock
        }
        throw ICPLedgerCanisterError.blockNotFound
    }
    
    private static func queryArchivedBlock(_ certification: ICPRequestCertification = .certified, _ method: CandidFunction.ServiceMethod, start: UInt64, length: UInt64, _ client: ICPRequestClient) async throws -> [ICPBlock] {
        let archivePrincipal = ICPPrincipal(method.principal.bytes)
        let queryArchiveMethod = ICPMethod(
            canister: archivePrincipal,
            methodName: method.name,
            args: .record([
                "start": .natural64(start),
                "length": .natural64(length),
            ])
        )
        let archiveResponse = try await client.query(certification, queryArchiveMethod, effectiveCanister: archivePrincipal)
        // "Ok", "Err"
        guard let archive = archiveResponse.variantValue,
              let ok = archive["Ok"]?.recordValue,
              let blocks = ok["blocks"]?.vectorValue?.values else {
            throw ICPLedgerCanisterError.invalidResponse
        }
        let icpBlocks = try blocks.map { try ICPBlock.from($0) }
        return icpBlocks
    }
}

// MARK: Block helpers
private extension ICPLedgerCanister {
    static func queryBlocksMethod(startAt index: UInt64, length: UInt64) -> ICPMethod {
        ICPMethod(
            canister: ICPSystemCanisters.ledger,
            methodName: "query_blocks",
            args: .record([
                "start": .natural64(index),
                "length": .natural64(length),
            ]))
    }
}

// MARK: balance helpers
private extension ICPLedgerCanister {
    static func accountBalanceMethod(_ account: ICPAccount) -> ICPMethod {
        ICPMethod(
            canister: ICPSystemCanisters.ledger,
            methodName: "account_balance",
            args: .record([
                "account": .blob(account.accountId)
            ])
        )
    }
    
    static func parseAccountBalanceResponse(_ response: CandidValue) throws -> UInt64 {
        guard let balance = response.ICPAmount else {
            throw ICPLedgerCanisterError.invalidResponse
        }
        return balance
    }
}

// Transfer helpers
private extension ICPLedgerCanister {
    static func transferMethod(from sendingAccount: ICPAccount,
                               to receivingAddress: String,
                               amount: UInt64,
                               fee: UInt64,
                               memo: UInt64?) -> ICPMethod {
        ICPMethod(
            canister: ICPSystemCanisters.ledger,
            methodName: "transfer",
            args: .record([
                "from_subaccount": .option(.blob(sendingAccount.subAccountId)),
                "to": .blob(Data.fromHex(receivingAddress)!),
                "amount": .ICPAmount(amount),
                "fee": .ICPAmount(fee),
                "memo": .natural64(memo ?? 0),
                "created_at_time": .ICPTimestampNow()
            ])
        )
    }
    
    static func parseTranserResponse(_ response: CandidValue) throws -> UInt64 {
        guard let variant = response.variantValue else {
            throw ICPLedgerCanisterError.invalidResponse
        }
        guard let blockIndex = variant["Ok"]?.natural64Value else {
            guard let error = variant["Err"]?.variantValue else {
                throw ICPLedgerCanisterError.invalidResponse
            }
            if let badFee = error["BadFee"]?.recordValue,
               let expectedFee = badFee["expected_fee"]?.ICPAmount {
                throw ICPTransferError.badFee(expectedFee: expectedFee)
                
            } else if let insufficientFunds = error["InsufficientFunds"]?.recordValue,
                      let balance = insufficientFunds["balance"]?.ICPAmount {
                
                throw ICPTransferError.insufficientFunds(balance: balance)
                                                      
            } else if let txTooOld = error["TxTooOld"]?.recordValue,
                      let allowed = txTooOld["allowed_window_nanos"]?.natural64Value {
                throw ICPTransferError.transactionTooOld(allowedWindowNanoSeconds: allowed)
                
            } else if let _ = error["TxCreatedInFuture"] {
                throw ICPTransferError.transactionCreatedInFuture
                
            } else if let txDuplicate = error["TxDuplicate"]?.recordValue,
                      let blockIndex = txDuplicate["duplicate_of"]?.natural64Value {
                throw ICPTransferError.transactionDuplicate(blockIndex: blockIndex)
            }
            throw ICPLedgerCanisterError.invalidResponse
        }
        return blockIndex
    }
}


private struct QueryBlockResponse {
    let chainLength: UInt64
    let firstBlockIndex: UInt64
    let certificate: Data?
    let blocks: [ICPBlock]
    let archivedBlocks: [ArchivedBlock]
    
    struct ArchivedBlock {
        let start: UInt64
        let length: UInt64
        let callback: CandidFunction
        
        static func from(_ candidValue: CandidValue) throws -> ArchivedBlock {
            guard let archivedBlock = candidValue.recordValue,
                  let start = archivedBlock["start"]?.natural64Value,
                  let length = archivedBlock["length"]?.natural64Value,
                  let callback = archivedBlock["callback"]?.functionValue else {
                throw ICPLedgerCanisterError.invalidResponse
            }
            return ArchivedBlock(start: start, length: length, callback: callback)
        }
    }
    
    static func from(_ candidValue: CandidValue) throws -> QueryBlockResponse {
        guard let queryBlockResponse = candidValue.recordValue,
              let chainLength = queryBlockResponse["chain_length"]?.natural64Value,
              let firstBlockIndex = queryBlockResponse["first_block_index"]?.natural64Value,
              let blockValues = queryBlockResponse["blocks"]?.vectorValue?.values,
              let archivedBlockValues = queryBlockResponse["archived_blocks"]?.vectorValue?.values,
              let optionalCertificate = queryBlockResponse["certificate"]?.optionValue else {
            throw ICPLedgerCanisterError.invalidResponse
        }
        let blocks = try blockValues.map { try ICPBlock.from($0) }
        let archivedBlocks = try archivedBlockValues.map { try ArchivedBlock.from($0) }
        return QueryBlockResponse(
            chainLength: chainLength,
            firstBlockIndex: firstBlockIndex,
            certificate: optionalCertificate.value?.blobValue,
            blocks: blocks,
            archivedBlocks: archivedBlocks
        )
    }
}

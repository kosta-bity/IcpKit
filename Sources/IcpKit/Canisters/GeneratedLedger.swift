//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 05.08.24.
//

import Foundation
import Candid
import BigInt

enum Ledger {
    /// // Account identifier  is a 32-byte array.
    /// // The first 4 bytes is big-endian encoding of a CRC32 checksum of the last 28 bytes
    /// type AccountIdentifier = blob;
    typealias AccountIdentifier = Data
    
    /// type BlockIndex = nat64;
    typealias BlockIndex = UInt64
    
    /// type Hash = blob;
    typealias Hash = Data
    
    /// // The ledger is a list of blocks
    /// type Ledger = vec Block;
    typealias Ledger = [Block]
    
    /// type Memo = nat64;
    typealias Memo = UInt64
    
    /// // A function that is used for fetching archived ledger blocks.
    /// type QueryArchiveFn = func (GetBlocksArgs) -> (QueryArchiveResult) query;
    typealias QueryArchiveFn = ICPFunction<GetBlocksArgs, QueryArchiveResult>
    
    /// type SubAccount = blob;
    typealias SubAccount = Data
    
    
    /// type AccountBalanceArgs = record {
    ///     account: AccountIdentifier;
    /// };
    struct AccountBalanceArgs: Codable {
        let account: AccountIdentifier
    }
    
    /// type Archive = record {
    ///     canister_id: principal;
    /// };
    struct Archive: Codable {
        let canister_id: CandidPrincipal
    }
    
    /// type Archives = record {
    ///     archives: vec Archive;
    /// };
    struct Archives: Codable {
        let archives: [Archive]
    }
    
    /// type Block = record {
    ///     parent_hash: opt Hash;
    ///     transaction: Transaction;
    ///     timestamp: TimeStamp;
    /// };
    struct Block: Codable {
        let transaction: Transaction
        let timestamp: TimeStamp
        let parent_hash: Hash?
    }
    
    /// // A prefix of the block range specified in the [GetBlocksArgs] request.
    /// type BlockRange = record {
    ///     // A prefix of the requested block range.
    ///     // The index of the first block is equal to [GetBlocksArgs.from].
    ///     //
    ///     // Note that the number of blocks might be less than the requested
    ///     // [GetBlocksArgs.len] for various reasons, for example:
    ///     //
    ///     // 1. The query might have hit the replica with an outdated state
    ///     //    that doesn't have the full block range yet.
    ///     // 2. The requested range is too large to fit into a single reply.
    ///     //
    ///     // NOTE: the list of blocks can be empty if:
    ///     // 1. [GetBlocksArgs.len] was zero.
    ///     // 2. [GetBlocksArgs.from] was larger than the last block known to the canister.
    ///     blocks : vec Block;
    /// };
    struct BlockRange: Codable {
        let blocks: [Block]
    }
    
    /// type GetBlocksArgs = record {
    ///     // The index of the first block to fetch.
    ///     start : BlockIndex;
    ///     // Max number of blocks to fetch.
    ///     length : nat64;
    /// };
    struct GetBlocksArgs: Codable {
        let start: BlockIndex
        let length: UInt64
    }
    
    /// type QueryArchiveResult = variant {
    ///     Ok : BlockRange;
    ///     Err : null;      // we don't know the values here...
    /// };
    enum QueryArchiveResult: Codable {
        case Ok(BlockRange)
        case Err
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// // The result of a "query_blocks" call.
    /// //
    /// // The structure of the result is somewhat complicated because the main ledger canister might
    /// // not have all the blocks that the caller requested: One or more "archive" canisters might
    /// // store some of the requested blocks.
    /// //
    /// // Note: as of Q4 2021 when this interface is authored, ICP doesn't support making nested
    /// // query calls within a query call.
    /// type QueryBlocksResponse = record {
    ///     // The total number of blocks in the chain.
    ///     // If the chain length is positive, the index of the last block is `chain_len - 1`.
    ///     chain_length : nat64;
    ///     // System certificate for the hash of the latest block in the chain.
    ///     // Only present if `query_blocks` is called in a non-replicated query context.
    ///     certificate : opt blob;
    ///     // List of blocks that were available in the ledger when it processed the call.
    ///     //
    ///     // The blocks form a contiguous range, with the first block having index
    ///     // [first_block_index] (see below), and the last block having index
    ///     // [first_block_index] + len(blocks) - 1.
    ///     //
    ///     // The block range can be an arbitrary sub-range of the originally requested range.
    ///     blocks : vec Block;
    ///     // The index of the first block in "blocks".
    ///     // If the blocks vector is empty, the exact value of this field is not specified.
    ///     first_block_index : BlockIndex;
    ///     // Encoding of instructions for fetching archived blocks whose indices fall into the
    ///     // requested range.
    ///     //
    ///     // For each entry `e` in [archived_blocks], `[e.from, e.from + len)` is a sub-range
    ///     // of the originally requested block range.
    ///     archived_blocks : vec record {
    ///         // The index of the first archived block that can be fetched using the callback.
    ///         start : BlockIndex;
    ///         // The number of blocks that can be fetched using the callback.
    ///         length : nat64;
    ///         // The function that should be called to fetch the archived blocks.
    ///         // The range of the blocks accessible using this function is given by [from]
    ///         // and [len] fields above.
    ///         callback : QueryArchiveFn;
    ///     };
    /// };
    struct QueryBlocksResponse: Codable {
        let certificate: Data?
        let blocks: [Block]
        let chain_length: UInt64
        let first_block_index: BlockIndex
        let archived_blocks: [UnnamedType0]
    }
    
    /// // Timestamps are represented as nanoseconds from the UNIX epoch in UTC timezone
    /// type TimeStamp = record {
    ///     timestamp_nanos: nat64;
    /// };
    struct TimeStamp: Codable {
        let timestamp_nanos: UInt64
    }
    
    /// // https://internetcomputer.org/docs/current/references/ledger/
    /// type Tokens = record {
    ///      e8s : nat64;
    /// };
    struct Tokens: Codable {
        let e8s: UInt64
    }
    
    /// type Transaction = record {
    ///     operation: opt Transfer;
    ///     memo: Memo;
    ///     created_at_time: TimeStamp;
    /// };
    struct Transaction: Codable {
        let memo: Memo
        let operation: Transfer?
        let created_at_time: TimeStamp
    }
    
    /// //There are three types of operations: minting tokens, burning tokens & transferring tokens
    /// type Transfer = variant {
    ///     Mint: record {
    ///         to: AccountIdentifier;
    ///         amount: Tokens;
    ///     };
    ///     Burn: record {
    ///          from: AccountIdentifier;
    ///          amount: Tokens;
    ///    };
    ///     Send: record {
    ///         from: AccountIdentifier;
    ///         to: AccountIdentifier;
    ///         amount: Tokens;
    ///     };
    /// };
    enum Transfer: Codable {
        case Burn(from: AccountIdentifier, amount: Tokens)
        case Mint(to: AccountIdentifier, amount: Tokens)
        case Send(to: AccountIdentifier, from: AccountIdentifier, amount: Tokens)
        
        enum CodingKeys: Int, CodingKey {
            case Burn = 737755247
            case Mint = 859142850
            case Send = 925481320
        }
    }
    
    /// // Arguments for the `transfer` call.
    /// type TransferArgs = record {
    ///     // Transaction memo.
    ///     // See comments for the `Memo` type.
    ///     memo: Memo;
    ///     // The amount that the caller wants to transfer to the destination address.
    ///     amount: Tokens;
    ///     // The amount that the caller pays for the transaction.
    ///     // Must be 10000 e8s.
    ///     fee: Tokens;
    ///     // The subaccount from which the caller wants to transfer funds.
    ///     // If null, the ledger uses the default (all zeros) subaccount to compute the source address.
    ///     // See comments for the `SubAccount` type.
    ///     from_subaccount: opt SubAccount;
    ///     // The destination account.
    ///     // If the transfer is successful, the balance of this address increases by `amount`.
    ///     to: AccountIdentifier;
    ///     // The point in time when the caller created this request.
    ///     // If null, the ledger uses current ICP time as the timestamp.
    ///     created_at_time: opt TimeStamp;
    /// };
    struct TransferArgs: Codable {
        let to: AccountIdentifier
        let fee: Tokens
        let memo: Memo
        let from_subaccount: SubAccount?
        let created_at_time: TimeStamp?
        let amount: Tokens
    }
    
    /// type TransferError = variant {
    ///     // The fee that the caller specified in the transfer request was not the one that ledger expects.
    ///     // The caller can change the transfer fee to the `expected_fee` and retry the request.
    ///     BadFee : record { expected_fee : Tokens; };
    ///     // The account specified by the caller doesn't have enough funds.
    ///     InsufficientFunds : record { balance: Tokens; };
    ///     // The request is too old.
    ///     // The ledger only accepts requests created within 24 hours window.
    ///     // This is a non-recoverable error.
    ///     TxTooOld : record { allowed_window_nanos: nat64 };
    ///     // The caller specified `created_at_time` that is too far in future.
    ///     // The caller can retry the request later.
    ///     TxCreatedInFuture : null;
    ///     // The ledger has already executed the request.
    ///     // `duplicate_of` field is equal to the index of the block containing the original transaction.
    ///     TxDuplicate : record { duplicate_of: BlockIndex; }
    /// };
    enum TransferError: Codable {
        case TxTooOld(allowed_window_nanos: UInt64)
        case BadFee(expected_fee: Tokens)
        case TxDuplicate(duplicate_of: BlockIndex)
        case TxCreatedInFuture
        case InsufficientFunds(balance: Tokens)
        
        enum CodingKeys: Int, CodingKey {
            case TxTooOld = 195874615
            case BadFee = 2142953889
            case TxDuplicate = 2932695879
            case TxCreatedInFuture = 4060984012
            case InsufficientFunds = 4206284395
        }
    }
    
    /// type TransferResult = variant {
    ///     Ok : BlockIndex;
    ///     Err : TransferError;
    /// };
    enum TransferResult: Codable {
        case Ok(BlockIndex)
        case Err(TransferError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    struct UnnamedType0: Codable {
        let callback: QueryArchiveFn
        let start: BlockIndex
        let length: UInt64
    }
    
    
    /// service : {
    ///   // Queries blocks in the specified range.
    ///   query_blocks : (GetBlocksArgs) -> (QueryBlocksResponse) query;
    ///   // Returns the existing archive canisters information.
    ///   archives : () -> (Archives) query;
    ///
    ///   // Get the amount of ICP on the specified account.
    ///   account_balance : (AccountBalanceArgs) -> (Tokens) query;
    ///   transfer : (TransferArgs) -> (TransferResult);
    /// }
    class Service: ICPService {
        /// // Queries blocks in the specified range.
        ///   query_blocks : (GetBlocksArgs) -> (QueryBlocksResponse) query;
        func query_blocks(_ arg0: GetBlocksArgs, sender: ICPSigningPrincipal? = nil) async throws -> QueryBlocksResponse {
            let caller = ICPFunction<GetBlocksArgs, QueryBlocksResponse>(canister, "query_blocks", query: true)
            let response = try await caller.callMethod(arg0, client, sender: sender)
            return response
        }
        
        /// // Returns the existing archive canisters information.
        ///   archives : () -> (Archives) query;
        func archives(sender: ICPSigningPrincipal? = nil) async throws -> Archives {
            let caller = ICPFunctionNoArgs<Archives>(canister, "archives", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// // Get the amount of ICP on the specified account.
        ///   account_balance : (AccountBalanceArgs) -> (Tokens) query;
        func account_balance(_ arg0: AccountBalanceArgs, sender: ICPSigningPrincipal? = nil) async throws -> Tokens {
            let caller = ICPFunction<AccountBalanceArgs, Tokens>(canister, "account_balance", query: true)
            let response = try await caller.callMethod(arg0, client, sender: sender)
            return response
        }
        
        /// transfer : (TransferArgs) -> (TransferResult);
        func transfer(_ arg0: TransferArgs, sender: ICPSigningPrincipal? = nil) async throws -> TransferResult {
            let caller = ICPFunction<TransferArgs, TransferResult>(canister, "transfer", query: false)
            let response = try await caller.callMethod(arg0, client, sender: sender)
            return response
        }
        
    }
    
}
enum TestCodeGeneration {
    typealias ABool = Bool
    
    typealias AData = Data
    
    typealias Function00 = ICPFunctionNoArgsNoResult
    
    typealias Function01 = ICPFunctionNoArgs<Bool>
    
    typealias Function02 = ICPFunctionNoArgs<CandidTuple2<Bool, String>>
    
    typealias Function03 = ICPFunctionNoArgs<CandidTuple3<Bool, String, Bool?>>
    
    typealias Function10 = ICPFunctionNoResult<Bool>
    
    typealias Function20 = ICPFunctionNoResult<CandidTuple2<Bool, String>>
    
    typealias Function30 = ICPFunctionNoResult<CandidTuple3<Bool, String, Bool?>>
    
    typealias RepeatedRecord = CandidTuple2<[Int8?], UInt8>
    
    typealias UnnamedType0 = CandidTuple2<[Int8?], UInt8>
    
    typealias VectorBool = [Bool]
    
    typealias VectorOptionalText = [String?]
    
    
    struct Record: Codable {
        let a: [BigInt?]
        let b: BigUInt
        let c: CandidTuple2<Bool, String>
    }
    
    class TestServiceDef: ICPService {
        func foo(_ arg0: UInt8, sender: ICPSigningPrincipal? = nil) async throws -> Int8 {
            let caller = ICPFunction<UInt8, Int8>(canister, "foo", query: false)
            let response = try await caller.callMethod(arg0, client, sender: sender)
            return response
        }
        
        func ref(sender: ICPSigningPrincipal? = nil) async throws -> Bool {
            let caller = Function01(canister, "ref", query: false)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
    }
    
    enum UnnamedVariant: Codable {
        case fall
        case winter
        case summer
        case spring
        
        enum CodingKeys: Int, CodingKey {
            case fall = 1135983739
            case winter = 1385738053
            case summer = 2706091375
            case spring = 3281376973
        }
    }
    
    enum Variant: Codable {
        case a
        case b(String)
        case c(String, BigInt)
        case d(one: Bool, two: Data, three: CandidTuple2<[Int8?], UInt8>)
        
        enum CodingKeys: Int, CodingKey {
            case a = 97
            case b = 98
            case c = 99
            case d = 100
        }
    }
    
    
    class TestService: ICPService {
        func noArgsNoResults(sender: ICPSigningPrincipal? = nil) async throws {
            let caller = ICPFunctionNoArgsNoResult(canister, "noArgsNoResults", query: false)
            let _ = try await caller.callMethod(client, sender: sender)
        }
        
        func singleUnnamedArg(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
            let caller = ICPFunctionNoResult<String>(canister, "singleUnnamedArg", query: true)
            let _ = try await caller.callMethod(arg0, client, sender: sender)
        }
        
        func singleUnnamedArgRecordWithUnnamedFields(_ arg0: CandidTuple2<Bool, String>, sender: ICPSigningPrincipal? = nil) async throws {
            let caller = ICPFunctionNoResult<CandidTuple2<Bool, String>>(canister, "singleUnnamedArgRecordWithUnnamedFields", query: false)
            let _ = try await caller.callMethod(arg0, client, sender: sender)
        }
        
        func singleNamedArg(myString: String, sender: ICPSigningPrincipal? = nil) async throws {
            let caller = ICPFunctionNoResult<String>(canister, "singleNamedArg", query: true)
            let _ = try await caller.callMethod(myString, client, sender: sender)
        }
        
        func singleUnnamedResult(sender: ICPSigningPrincipal? = nil) async throws -> Bool? {
            let caller = ICPFunctionNoArgs<Bool?>(canister, "singleUnnamedResult", query: false)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        func singleNamedResult(sender: ICPSigningPrincipal? = nil) async throws -> String {
            let caller = ICPFunctionNoArgs<String>(canister, "singleNamedResult", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        func multipleUnnamedArgsAndResults(_ arg0: String, _ arg1: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> (Bool?, [Data]) {
            let caller = ICPFunction<CandidTuple2<String, [BigUInt]>, CandidTuple2<Bool?, [Data]>>(canister, "multipleUnnamedArgsAndResults", query: false)
            let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
            return response.tuple
        }
        
        func multipleNamedArgsAndResults(name: String, ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> (out1: Bool?, out2: [Data]) {
            let caller = ICPFunction<CandidTuple2<String, [BigUInt]>, CandidTuple2<Bool?, [Data]>>(canister, "multipleNamedArgsAndResults", query: false)
            let response = try await caller.callMethod(.init(name, ids), client, sender: sender)
            return response.tuple
        }
        
        func functionReference(sender: ICPSigningPrincipal? = nil) async throws -> Bool {
            let caller = Function01(canister, "functionReference", query: false)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
    }
    
}

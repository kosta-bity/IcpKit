//
// This file was generated using CandidCodeGenerator
// created: 2024-08-05 13:02:54 +0000
//
// You can modify this file if needed
//

import Foundation
import Candid
import BigInt

enum ICRC7 {
    /// // https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.did
    /// type Subaccount = blob;
    typealias Subaccount = Data
    
    
    /// type Account = record { owner : principal; subaccount : opt Subaccount };
    struct Account: Codable {
        let owner: CandidPrincipal
        let subaccount: Subaccount?
    }
    
    /// type TransferArg = record {
    ///     from_subaccount: opt blob; // The subaccount to transfer the token from
    ///     to : Account;
    ///     token_id : nat;
    ///     memo : opt blob;
    ///     created_at_time : opt nat64;
    /// };
    struct TransferArg: Codable {
        let to: Account
        let token_id: BigUInt
        let memo: Data?
        let from_subaccount: Data?
        let created_at_time: UInt64?
    }
    
    /// type TransferError = variant {
    ///     NonExistingTokenId;
    ///     InvalidRecipient;
    ///     Unauthorized;
    ///     TooOld;
    ///     CreatedInFuture : record { ledger_time: nat64 };
    ///     Duplicate : record { duplicate_of : nat };
    ///     GenericError : record { error_code : nat; message : text };
    ///     GenericBatchError : record { error_code : nat; message : text };
    /// };
    enum TransferError: Codable {
        case GenericError(message: String, error_code: BigUInt)
        case Duplicate(duplicate_of: BigUInt)
        case NonExistingTokenId
        case Unauthorized
        case CreatedInFuture(ledger_time: UInt64)
        case InvalidRecipient
        case GenericBatchError(message: String, error_code: BigUInt)
        case TooOld
        
        enum CodingKeys: Int, CodingKey {
            case GenericError = 260448849
            case Duplicate = 1122632043
            case NonExistingTokenId = 1457030524
            case Unauthorized = 2471582292
            case CreatedInFuture = 2608432112
            case InvalidRecipient = 2765571586
            case GenericBatchError = 3005770373
            case TooOld = 3373249171
        }
    }
    
    /// type TransferResult = variant {
    ///     Ok : nat; // Transaction index for successful transfer
    ///     Err : TransferError;
    /// };
    enum TransferResult: Codable {
        case Ok(BigUInt)
        case Err(TransferError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// // Generic value in accordance with ICRC-3
    /// type Value = variant {
    ///     Blob : blob;
    ///     Text : text;
    ///     Nat : nat;
    ///     Int : int;
    ///     Array : vec Value;
    ///     Map : vec record { text; Value };
    /// };
    enum Value: Codable {
        case Int(BigInt)
        case Map([CandidTuple2<String, Value>])
        case Nat(BigUInt)
        case Blob(Data)
        case Text(String)
        case Array([Value])
        
        enum CodingKeys: Int, CodingKey {
            case Int = 3654863
            case Map = 3850876
            case Nat = 3900609
            case Blob = 737307005
            case Text = 936573133
            case Array = 3099385209
        }
    }
    
    
    /// service : {
    ///   icrc7_collection_metadata : () -> (vec record { text; Value } ) query;
    ///   icrc7_symbol : () -> (text) query;
    ///   icrc7_name : () -> (text) query;
    ///   icrc7_description : () -> (opt text) query;
    ///   icrc7_logo : () -> (opt text) query;
    ///   icrc7_total_supply : () -> (nat) query;
    ///   icrc7_supply_cap : () -> (opt nat) query;
    ///   icrc7_max_query_batch_size : () -> (opt nat) query;
    ///   icrc7_max_update_batch_size : () -> (opt nat) query;
    ///   icrc7_default_take_value : () -> (opt nat) query;
    ///   icrc7_max_take_value : () -> (opt nat) query;
    ///   icrc7_max_memo_size : () -> (opt nat) query;
    ///   icrc7_atomic_batch_transfers : () -> (opt bool) query;
    ///   icrc7_tx_window : () -> (opt nat) query;
    ///   icrc7_permitted_drift : () -> (opt nat) query;
    ///   icrc7_token_metadata : (token_ids : vec nat)
    ///       -> (vec opt vec record { text; Value }) query;
    ///   icrc7_owner_of : (token_ids : vec nat)
    ///       -> (vec opt Account) query;
    ///   icrc7_balance_of : (vec Account) -> (vec nat) query;
    ///   icrc7_tokens : (prev : opt nat, take : opt nat)
    ///       -> (vec nat) query;
    ///   icrc7_tokens_of : (account : Account, prev : opt nat, take : opt nat)
    ///       -> (vec nat) query;
    ///   icrc7_transfer : (vec TransferArg) -> (vec opt TransferResult);
    /// }
    class Service {
        let canister: ICPPrincipal
        let client: ICPRequestClient
        
        init(canister: ICPPrincipal, client: ICPRequestClient) {
            self.canister = canister
            self.client = client
        }
        
        /// icrc7_collection_metadata : () -> (vec record { text; Value } ) query;
        func icrc7_collection_metadata(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<String, Value>] {
            let caller = ICPFunctionNoArgs<[CandidTuple2<String, Value>]>(canister, "icrc7_collection_metadata", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_symbol : () -> (text) query;
        func icrc7_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String {
            let caller = ICPFunctionNoArgs<String>(canister, "icrc7_symbol", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_name : () -> (text) query;
        func icrc7_name(sender: ICPSigningPrincipal? = nil) async throws -> String {
            let caller = ICPFunctionNoArgs<String>(canister, "icrc7_name", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_description : () -> (opt text) query;
        func icrc7_description(sender: ICPSigningPrincipal? = nil) async throws -> String? {
            let caller = ICPFunctionNoArgs<String?>(canister, "icrc7_description", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_logo : () -> (opt text) query;
        func icrc7_logo(sender: ICPSigningPrincipal? = nil) async throws -> String? {
            let caller = ICPFunctionNoArgs<String?>(canister, "icrc7_logo", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_total_supply : () -> (nat) query;
        func icrc7_total_supply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let caller = ICPFunctionNoArgs<BigUInt>(canister, "icrc7_total_supply", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_supply_cap : () -> (opt nat) query;
        func icrc7_supply_cap(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_supply_cap", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_max_query_batch_size : () -> (opt nat) query;
        func icrc7_max_query_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_max_query_batch_size", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_max_update_batch_size : () -> (opt nat) query;
        func icrc7_max_update_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_max_update_batch_size", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_default_take_value : () -> (opt nat) query;
        func icrc7_default_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_default_take_value", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_max_take_value : () -> (opt nat) query;
        func icrc7_max_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_max_take_value", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_max_memo_size : () -> (opt nat) query;
        func icrc7_max_memo_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_max_memo_size", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_atomic_batch_transfers : () -> (opt bool) query;
        func icrc7_atomic_batch_transfers(sender: ICPSigningPrincipal? = nil) async throws -> Bool? {
            let caller = ICPFunctionNoArgs<Bool?>(canister, "icrc7_atomic_batch_transfers", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_tx_window : () -> (opt nat) query;
        func icrc7_tx_window(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_tx_window", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        /// icrc7_permitted_drift : () -> (opt nat) query;
        func icrc7_permitted_drift(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let caller = ICPFunctionNoArgs<BigUInt?>(canister, "icrc7_permitted_drift", query: true)
            let response = try await caller.callMethod(client, sender: sender)
            return response
        }
        
        func icrc7_token_metadata(token_ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [[CandidTuple2<String, Value>]?] {
            let caller = ICPFunction<[BigUInt], [[CandidTuple2<String, Value>]?]>(canister, "icrc7_token_metadata", query: true)
            let response = try await caller.callMethod(token_ids, client, sender: sender)
            return response
        }
        
        func icrc7_owner_of(token_ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [Account?] {
            let caller = ICPFunction<[BigUInt], [Account?]>(canister, "icrc7_owner_of", query: true)
            let response = try await caller.callMethod(token_ids, client, sender: sender)
            return response
        }
        
        /// icrc7_balance_of : (vec Account) -> (vec nat) query;
        func icrc7_balance_of(_ arg0: [Account], sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let caller = ICPFunction<[Account], [BigUInt]>(canister, "icrc7_balance_of", query: true)
            let response = try await caller.callMethod(arg0, client, sender: sender)
            return response
        }
        
        func icrc7_tokens(prev: BigUInt?, take: BigUInt?, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let caller = ICPFunction<CandidTuple2<BigUInt?, BigUInt?>, [BigUInt]>(canister, "icrc7_tokens", query: true)
            let response = try await caller.callMethod(.init(prev, take), client, sender: sender)
            return response
        }
        
        func icrc7_tokens_of(account: Account, prev: BigUInt?, take: BigUInt?, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let caller = ICPFunction<CandidTuple3<Account, BigUInt?, BigUInt?>, [BigUInt]>(canister, "icrc7_tokens_of", query: true)
            let response = try await caller.callMethod(.init(account, prev, take), client, sender: sender)
            return response
        }
        
        /// icrc7_transfer : (vec TransferArg) -> (vec opt TransferResult);
        func icrc7_transfer(_ arg0: [TransferArg], sender: ICPSigningPrincipal? = nil) async throws -> [TransferResult?] {
            let caller = ICPFunction<[TransferArg], [TransferResult?]>(canister, "icrc7_transfer", query: false)
            let response = try await caller.callMethod(arg0, client, sender: sender)
            return response
        }
        
    }
    
}
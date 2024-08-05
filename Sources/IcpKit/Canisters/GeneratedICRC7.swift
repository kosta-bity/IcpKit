//
// This file was generated using CandidCodeGenerator
// created: 2024-08-05 10:59:09 +0000
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
    
    struct UnnamedType0: Codable {
        let _0: String
        let _1: Value
        
        init(_ _0: String, _ _1: Value) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType1: Codable {
        let prev: BigUInt?
        let take: BigUInt?
    }
    
    struct UnnamedType2: Codable {
        let prev: BigUInt?
        let take: BigUInt?
        let account: Account
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
        case Map([UnnamedType0])
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
        func icrc7_collection_metadata(sender: ICPSigningPrincipal? = nil) async throws -> [UnnamedType0] {
            let caller = ICPFunctionNoArgs<[UnnamedType0]>(canister, "icrc7_collection_metadata", query: true)
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
        
        func icrc7_token_metadata(token_ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [[UnnamedType0]?] {
            let caller = ICPFunction<[BigUInt], [[UnnamedType0]?]>(canister, "icrc7_token_metadata", query: true)
            let response = try await caller.callMethod(token_ids, client, sender: sender)
            return response
        }
        
        func icrc7_owner_of(token_ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [Account?] {
            let caller = ICPFunction<[BigUInt], [Account?]>(canister, "icrc7_owner_of", query: true)
            let response = try await caller.callMethod(token_ids, client, sender: sender)
            return response
        }
        
        /// icrc7_balance_of : (vec Account) -> (vec nat) query;
        func icrc7_balance_of(_ args: [Account], sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let caller = ICPFunction<[Account], [BigUInt]>(canister, "icrc7_balance_of", query: true)
            let response = try await caller.callMethod(args, client, sender: sender)
            return response
        }
        
        func icrc7_tokens(_ args: UnnamedType1, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let caller = ICPFunction<UnnamedType1, [BigUInt]>(canister, "icrc7_tokens", query: true)
            let response = try await caller.callMethod(args, client, sender: sender)
            return response
        }
        
        func icrc7_tokens_of(_ args: UnnamedType2, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let caller = ICPFunction<UnnamedType2, [BigUInt]>(canister, "icrc7_tokens_of", query: true)
            let response = try await caller.callMethod(args, client, sender: sender)
            return response
        }
        
        /// icrc7_transfer : (vec TransferArg) -> (vec opt TransferResult);
        func icrc7_transfer(_ args: [TransferArg], sender: ICPSigningPrincipal? = nil) async throws -> [TransferResult?] {
            let caller = ICPFunction<[TransferArg], [TransferResult?]>(canister, "icrc7_transfer", query: false)
            let response = try await caller.callMethod(args, client, sender: sender)
            return response
        }
        
    }
    
}

enum TestCodeGeneration {
    typealias ABool = Bool
    
    typealias AData = Data
    
    typealias Function1 = ICPFunctionNoArgsNoResult
    
    typealias UnnamedType0_0 = RepeatedRecord
    
    typealias VectorBool = [Bool]
    
    typealias VectorOptionalText = [String?]
    
    
    struct Record: Codable {
        let a: [BigInt?]
        let b: BigUInt
        let c: UnnamedType0
    }
    
    struct RepeatedRecord: Codable {
        let _0: [Int8?]
        let _1: UInt8
        
        init(_ _0: [Int8?], _ _1: UInt8) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    class TestServiceDef {
        let canister: ICPPrincipal
        let client: ICPRequestClient
        
        init(canister: ICPPrincipal, client: ICPRequestClient) {
            self.canister = canister
            self.client = client
        }
        
        func foo(_ args: UInt8, sender: ICPSigningPrincipal? = nil) async throws -> Int8 {
            let caller = ICPFunction<UInt8, Int8>(canister, "foo", query: false)
            let response = try await caller.callMethod(args, client, sender: sender)
            return response
        }
        
        func ref(sender: ICPSigningPrincipal? = nil) async throws {
            let caller = Function1(canister, "ref", query: false)
            let _ = try await caller.callMethod(client, sender: sender)
        }
        
    }
    
    struct UnnamedType0: Codable {
        let _0: Bool
        let _1: String
        
        init(_ _0: Bool, _ _1: String) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType1: Codable {
        let _0: String
        let _1: [BigUInt]
        
        init(_ _0: String, _ _1: [BigUInt]) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType2: Codable {
        let _0: Bool?
        let _1: [Data]
        
        init(_ _0: Bool?, _ _1: [Data]) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType3: Codable {
        let ids: [BigUInt]
        let name: String
    }
    
    struct UnnamedType4: Codable {
        let out1: Bool?
        let out2: [Data]
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
        case d(one: Bool, two: Data, three: RepeatedRecord)
        
        enum CodingKeys: Int, CodingKey {
            case a = 97
            case b = 98
            case c = 99
            case d = 100
        }
    }
    
    
    class TestService {
        let canister: ICPPrincipal
        let client: ICPRequestClient
        
        init(canister: ICPPrincipal, client: ICPRequestClient) {
            self.canister = canister
            self.client = client
        }
        
        func noArgsNoResults(sender: ICPSigningPrincipal? = nil) async throws {
            let caller = ICPFunctionNoArgsNoResult(canister, "noArgsNoResults", query: false)
            let _ = try await caller.callMethod(client, sender: sender)
        }
        
        func singleUnnamedArg(_ args: String, sender: ICPSigningPrincipal? = nil) async throws {
            let caller = ICPFunctionNoResult<String>(canister, "singleUnnamedArg", query: true)
            let _ = try await caller.callMethod(args, client, sender: sender)
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
        
        func multipleUnnamedArgsAndResults(_ args: UnnamedType1, sender: ICPSigningPrincipal? = nil) async throws -> UnnamedType2 {
            let caller = ICPFunction<UnnamedType1, UnnamedType2>(canister, "multipleUnnamedArgsAndResults", query: false)
            let response = try await caller.callMethod(args, client, sender: sender)
            return response
        }
        
        func multipleNamedArgsAndResults(_ args: UnnamedType3, sender: ICPSigningPrincipal? = nil) async throws -> UnnamedType4 {
            let caller = ICPFunction<UnnamedType3, UnnamedType4>(canister, "multipleNamedArgsAndResults", query: false)
            let response = try await caller.callMethod(args, client, sender: sender)
            return response
        }
        
        func functionReference(sender: ICPSigningPrincipal? = nil) async throws {
            let caller = Function1(canister, "functionReference", query: false)
            let _ = try await caller.callMethod(client, sender: sender)
        }
        
    }
    
}

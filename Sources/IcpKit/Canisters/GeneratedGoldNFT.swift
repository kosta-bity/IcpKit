//
// This file was generated using CandidCodeGenerator
// created: 2024-08-02 13:37:13 +0000
//
// You can modify this file if needed
//

import Foundation
import Candid
import BigInt

enum GoldNFT {
    /// type Account__1 = variant {
    ///   account_id : text;
    ///   "principal" : principal;
    ///   extensible : CandyShared;
    ///   account : record { owner : principal; sub_account : opt vec nat8 };
    /// };
    typealias Account__1 = Account
    
    /// type Account__2 = variant {
    ///   account_id : text;
    ///   "principal" : principal;
    ///   extensible : CandyShared;
    ///   account : record { owner : principal; sub_account : opt vec nat8 };
    /// };
    typealias Account__2 = Account
    
    /// type ApprovalResult = vec record {
    ///   token_id : nat;
    ///   approval_result : variant { Ok : nat; Err : ApprovalError };
    /// };
    typealias ApprovalResult = [UnnamedType1]
    
    /// type AskConfigShared = opt AskFeatureArray;
    typealias AskConfigShared = AskFeatureArray?
    
    /// type AskFeatureArray = vec AskFeature;
    typealias AskFeatureArray = [AskFeature]
    
    /// type AskSubscribeResponse = bool;
    typealias AskSubscribeResponse = Bool
    
    /// type BidConfigShared = opt vec BidFeature;
    typealias BidConfigShared = [BidFeature]?
    
    /// type Caller = opt principal;
    typealias Caller = CandidPrincipal?
    
    /// type CandyShared = variant {
    ///   Int : int;
    ///   Map : vec record { CandyShared; CandyShared };
    ///   Nat : nat;
    ///   Set : vec CandyShared;
    ///   Nat16 : nat16;
    ///   Nat32 : nat32;
    ///   Nat64 : nat64;
    ///   Blob : vec nat8;
    ///   Bool : bool;
    ///   Int8 : int8;
    ///   Ints : vec int;
    ///   Nat8 : nat8;
    ///   Nats : vec nat;
    ///   Text : text;
    ///   Bytes : vec nat8;
    ///   Int16 : int16;
    ///   Int32 : int32;
    ///   Int64 : int64;
    ///   Option : opt CandyShared;
    ///   Floats : vec float64;
    ///   Float : float64;
    ///   Principal : principal;
    ///   Array : vec CandyShared;
    ///   Class : vec PropertyShared;
    /// };
    typealias CandyShared = C_Data
    
    /// type CanisterCyclesAggregatedData = vec nat64;
    typealias CanisterCyclesAggregatedData = [UInt64]
    
    /// type CanisterHeapMemoryAggregatedData = vec nat64;
    typealias CanisterHeapMemoryAggregatedData = [UInt64]
    
    /// type CanisterMemoryAggregatedData = vec nat64;
    typealias CanisterMemoryAggregatedData = [UInt64]
    
    /// type CollectionMetadata = vec record { text; Value };
    typealias CollectionMetadata = [UnnamedType12]
    
    /// type DistributeSaleResponse = vec Result;
    typealias DistributeSaleResponse = [Result]
    
    /// type EXTAccountIdentifier = text;
    typealias EXTAccountIdentifier = String
    
    /// type EXTBalance = nat;
    typealias EXTBalance = BigUInt
    
    /// type EXTMemo = vec nat8;
    typealias EXTMemo = Data
    
    /// type EXTSubAccount = vec nat8;
    typealias EXTSubAccount = Data
    
    /// type EXTTokenIdentifier = text;
    typealias EXTTokenIdentifier = String
    
    /// type EndSaleResponse = record {
    ///   token_id : text;
    ///   txn_type : variant {
    ///     escrow_deposit : record {
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     fee_deposit : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_network_updated : record {
    ///       network : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     escrow_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_managers_updated : record {
    ///       managers : vec principal;
    ///       extensible : CandyShared;
    ///     };
    ///     auction_bid : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : text;
    ///     };
    ///     burn : record { from : opt Account__1; extensible : CandyShared };
    ///     data : record {
    ///       hash : opt vec nat8;
    ///       extensible : CandyShared;
    ///       data_dapp : opt text;
    ///       data_path : opt text;
    ///     };
    ///     sale_ended : record {
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : opt text;
    ///     };
    ///     mint : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       sale : opt record { token : TokenSpec; amount : nat };
    ///       extensible : CandyShared;
    ///     };
    ///     royalty_paid : record {
    ///       tag : text;
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       receiver : Account__1;
    ///       sale_id : opt text;
    ///     };
    ///     extensible : CandyShared;
    ///     fee_deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     owner_transfer : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_opened : record {
    ///       pricing : PricingConfigShared;
    ///       extensible : CandyShared;
    ///       sale_id : text;
    ///     };
    ///     canister_owner_updated : record {
    ///       owner : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///   };
    ///   timestamp : int;
    ///   index : nat;
    /// };
    typealias EndSaleResponse = BidResponse
    
    /// type EscrowReceipt__1 = record {
    ///   token : TokenSpec;
    ///   token_id : text;
    ///   seller : Account__1;
    ///   buyer : Account__1;
    ///   amount : nat;
    /// };
    typealias EscrowReceipt__1 = EscrowReceipt
    
    /// type FeeAccountsParams = vec FeeName;
    typealias FeeAccountsParams = [FeeName]
    
    /// type FeeName = text;
    typealias FeeName = String
    
    /// type GetArchivesResult = vec GetArchivesResultItem;
    typealias GetArchivesResult = [GetArchivesResultItem]
    
    /// type GetTransactionsFn = func (vec TransactionRange__1) -> (
    ///     GetTransactionsResult__1,
    ///   ) query;
    typealias GetTransactionsFn = ICPFunction<[TransactionRange__1], GetTransactionsResult__1>
    
    /// type GetTransactionsResult__1 = record {
    ///   log_length : nat;
    ///   blocks : vec record { id : nat; block : Value__1 };
    ///   archived_blocks : vec ArchivedTransactionResponse;
    /// };
    typealias GetTransactionsResult__1 = GetTransactionsResult
    
    /// type ICTokenSpec__1 = record {
    ///   id : opt nat;
    ///   fee : opt nat;
    ///   decimals : nat;
    ///   canister : principal;
    ///   standard : variant { ICRC1; EXTFungible; DIP20; Other : CandyShared; Ledger };
    ///   symbol : text;
    /// };
    typealias ICTokenSpec__1 = ICTokenSpec
    
    /// type InstantConfigShared = opt vec InstantFeature;
    typealias InstantConfigShared = [InstantFeature]?
    
    /// type MarketTransferRequestReponse = record {
    ///   token_id : text;
    ///   txn_type : variant {
    ///     escrow_deposit : record {
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     fee_deposit : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_network_updated : record {
    ///       network : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     escrow_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_managers_updated : record {
    ///       managers : vec principal;
    ///       extensible : CandyShared;
    ///     };
    ///     auction_bid : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : text;
    ///     };
    ///     burn : record { from : opt Account__1; extensible : CandyShared };
    ///     data : record {
    ///       hash : opt vec nat8;
    ///       extensible : CandyShared;
    ///       data_dapp : opt text;
    ///       data_path : opt text;
    ///     };
    ///     sale_ended : record {
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : opt text;
    ///     };
    ///     mint : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       sale : opt record { token : TokenSpec; amount : nat };
    ///       extensible : CandyShared;
    ///     };
    ///     royalty_paid : record {
    ///       tag : text;
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       receiver : Account__1;
    ///       sale_id : opt text;
    ///     };
    ///     extensible : CandyShared;
    ///     fee_deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     owner_transfer : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_opened : record {
    ///       pricing : PricingConfigShared;
    ///       extensible : CandyShared;
    ///       sale_id : text;
    ///     };
    ///     canister_owner_updated : record {
    ///       owner : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///   };
    ///   timestamp : int;
    ///   index : nat;
    /// };
    typealias MarketTransferRequestReponse = BidResponse
    
    /// type NFTUpdateResponse = bool;
    typealias NFTUpdateResponse = Bool
    
    /// type Nanos = nat64;
    typealias Nanos = UInt64
    
    /// type PricingConfigShared__1 = variant {
    ///   ask : AskConfigShared;
    ///   extensible : CandyShared;
    ///   instant : InstantConfigShared;
    ///   auction : AuctionConfig;
    /// };
    typealias PricingConfigShared__1 = PricingConfigShared
    
    /// type Result = variant { ok : ManageSaleResponse; err : OrigynError };
    typealias Result = ManageSaleResult
    
    /// type StableEscrowBalances = vec record {
    ///   Account;
    ///   Account;
    ///   text;
    ///   EscrowRecord__1;
    /// };
    typealias StableEscrowBalances = [UnnamedType39]
    
    /// type StableNftLedger = vec record { text; TransactionRecord };
    typealias StableNftLedger = [UnnamedType40]
    
    /// type StableOffers = vec record { Account; Account; int };
    typealias StableOffers = [UnnamedType41]
    
    /// type StableSalesBalances = vec record {
    ///   Account;
    ///   Account;
    ///   text;
    ///   EscrowRecord__1;
    /// };
    typealias StableSalesBalances = [UnnamedType39]
    
    /// type Subaccount = vec nat8;
    typealias Subaccount = Data
    
    /// type TokenSpec__2 = variant { ic : ICTokenSpec; extensible : CandyShared };
    typealias TokenSpec__2 = TokenSpec
    
    /// type TransactionID__1 = variant {
    ///   "nat" : nat;
    ///   "text" : text;
    ///   extensible : CandyShared;
    /// };
    typealias TransactionID__1 = TransactionID
    
    /// type TransactionRange__1 = record { start : nat; length : nat };
    typealias TransactionRange__1 = TransactionRange
    
    /// type TransactionRecord = record {
    ///   token_id : text;
    ///   txn_type : variant {
    ///     escrow_deposit : record {
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     fee_deposit : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_network_updated : record {
    ///       network : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     escrow_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_managers_updated : record {
    ///       managers : vec principal;
    ///       extensible : CandyShared;
    ///     };
    ///     auction_bid : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : text;
    ///     };
    ///     burn : record { from : opt Account__1; extensible : CandyShared };
    ///     data : record {
    ///       hash : opt vec nat8;
    ///       extensible : CandyShared;
    ///       data_dapp : opt text;
    ///       data_path : opt text;
    ///     };
    ///     sale_ended : record {
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : opt text;
    ///     };
    ///     mint : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       sale : opt record { token : TokenSpec; amount : nat };
    ///       extensible : CandyShared;
    ///     };
    ///     royalty_paid : record {
    ///       tag : text;
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       receiver : Account__1;
    ///       sale_id : opt text;
    ///     };
    ///     extensible : CandyShared;
    ///     fee_deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     owner_transfer : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_opened : record {
    ///       pricing : PricingConfigShared;
    ///       extensible : CandyShared;
    ///       sale_id : text;
    ///     };
    ///     canister_owner_updated : record {
    ///       owner : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///   };
    ///   timestamp : int;
    ///   index : nat;
    /// };
    typealias TransactionRecord = BidResponse
    
    /// type TransferResult = vec opt TransferResultItem;
    typealias TransferResult = [TransferResultItem?]
    
    /// type UpdateCallsAggregatedData = vec nat64;
    typealias UpdateCallsAggregatedData = [UInt64]
    
    /// type Vec = vec record {
    ///   text;
    ///   variant {
    ///     Nat64Content : nat64;
    ///     Nat32Content : nat32;
    ///     BoolContent : bool;
    ///     Nat8Content : nat8;
    ///     Int64Content : int64;
    ///     IntContent : int;
    ///     NatContent : nat;
    ///     Nat16Content : nat16;
    ///     Int32Content : int32;
    ///     Int8Content : int8;
    ///     FloatContent : float64;
    ///     Int16Content : int16;
    ///     BlobContent : vec nat8;
    ///     NestedContent : Vec;
    ///     Principal : principal;
    ///     TextContent : text;
    ///   };
    /// };
    typealias Vec = [UnnamedType45]
    
    /// type WithdrawResponse = record {
    ///   token_id : text;
    ///   txn_type : variant {
    ///     escrow_deposit : record {
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     fee_deposit : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_network_updated : record {
    ///       network : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     escrow_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_managers_updated : record {
    ///       managers : vec principal;
    ///       extensible : CandyShared;
    ///     };
    ///     auction_bid : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : text;
    ///     };
    ///     burn : record { from : opt Account__1; extensible : CandyShared };
    ///     data : record {
    ///       hash : opt vec nat8;
    ///       extensible : CandyShared;
    ///       data_dapp : opt text;
    ///       data_path : opt text;
    ///     };
    ///     sale_ended : record {
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : opt text;
    ///     };
    ///     mint : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       sale : opt record { token : TokenSpec; amount : nat };
    ///       extensible : CandyShared;
    ///     };
    ///     royalty_paid : record {
    ///       tag : text;
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       receiver : Account__1;
    ///       sale_id : opt text;
    ///     };
    ///     extensible : CandyShared;
    ///     fee_deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     owner_transfer : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_opened : record {
    ///       pricing : PricingConfigShared;
    ///       extensible : CandyShared;
    ///       sale_id : text;
    ///     };
    ///     canister_owner_updated : record {
    ///       owner : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///   };
    ///   timestamp : int;
    ///   index : nat;
    /// };
    typealias WithdrawResponse = BidResponse
    
    /// type canister_id = principal;
    typealias canister_id = CandidPrincipal
    
    
    /// type Account = variant {
    ///   account_id : text;
    ///   "principal" : principal;
    ///   extensible : CandyShared;
    ///   account : record { owner : principal; sub_account : opt vec nat8 };
    /// };
    enum Account: Codable {
        case account_id(String)
        case principal(CandidPrincipal)
        case extensible(CandyShared)
        case account(owner: CandidPrincipal, sub_account: Data?)
        
        enum CodingKeys: Int, CodingKey {
            case account_id = 11394925
            case principal = 302796462
            case extensible = 2305203451
            case account = 2707029165
        }
    }
    
    /// type Account__3 = record { owner : principal; subaccount : opt Subaccount };
    struct Account__3: Codable {
        let owner: CandidPrincipal
        let subaccount: Subaccount?
    }
    
    /// type AllocationRecordStable = record {
    ///   allocated_space : nat;
    ///   token_id : text;
    ///   available_space : nat;
    ///   canister : principal;
    ///   chunks : vec nat;
    ///   library_id : text;
    /// };
    struct AllocationRecordStable: Codable {
        let allocated_space: BigUInt
        let token_id: String
        let available_space: BigUInt
        let canister: CandidPrincipal
        let chunks: [BigUInt]
        let library_id: String
    }
    
    /// type ApprovalArgs = record {
    ///   memo : opt vec nat8;
    ///   from_subaccount : opt vec nat8;
    ///   created_at_time : opt nat64;
    ///   expires_at : opt nat64;
    ///   spender : Account__3;
    /// };
    struct ApprovalArgs: Codable {
        let memo: Data?
        let from_subaccount: Data?
        let created_at_time: UInt64?
        let expires_at: UInt64?
        let spender: Account__3
    }
    
    /// type ApprovalError = variant {
    ///   GenericError : record { message : text; error_code : nat };
    ///   CreatexInFuture : record { ledger_time : nat64 };
    ///   NonExistingTokenId;
    ///   Unauthorized;
    ///   TooOld;
    /// };
    enum ApprovalError: Codable {
        case GenericError(message: String, error_code: BigUInt)
        case CreatexInFuture(ledger_time: UInt64)
        case NonExistingTokenId
        case Unauthorized
        case TooOld
        
        enum CodingKeys: Int, CodingKey {
            case GenericError = 260448849
            case CreatexInFuture = 374716420
            case NonExistingTokenId = 1457030524
            case Unauthorized = 2471582292
            case TooOld = 3373249171
        }
    }
    
    /// type ArchivedTransactionResponse = record {
    ///   args : vec TransactionRange__1;
    ///   callback : GetTransactionsFn;
    /// };
    struct ArchivedTransactionResponse: Codable {
        let args: [TransactionRange__1]
        let callback: GetTransactionsFn
    }
    
    /// type AskFeature = variant {
    ///   kyc : principal;
    ///   start_price : nat;
    ///   token : TokenSpec;
    ///   fee_schema : text;
    ///   notify : vec principal;
    ///   wait_for_quiet : WaitForQuietType;
    ///   reserve : nat;
    ///   start_date : int;
    ///   min_increase : MinIncreaseType;
    ///   allow_list : vec principal;
    ///   buy_now : nat;
    ///   fee_accounts : FeeAccountsParams;
    ///   nifty_settlement : NiftySettlementType;
    ///   atomic;
    ///   dutch : DutchParams;
    ///   ending : EndingType;
    /// };
    enum AskFeature: Codable {
        case kyc(CandidPrincipal)
        case start_price(BigUInt)
        case token(TokenSpec)
        case fee_schema(String)
        case notify([CandidPrincipal])
        case wait_for_quiet(WaitForQuietType)
        case reserve(BigUInt)
        case start_date(BigInt)
        case min_increase(MinIncreaseType)
        case allow_list([CandidPrincipal])
        case buy_now(BigUInt)
        case fee_accounts(FeeAccountsParams)
        case nifty_settlement(NiftySettlementType)
        case atomic
        case dutch(DutchParams)
        case ending(EndingType)
        
        enum CodingKeys: Int, CodingKey {
            case kyc = 5348085
            case start_price = 130318252
            case token = 338395897
            case fee_schema = 386492474
            case notify = 834198217
            case wait_for_quiet = 1541627444
            case reserve = 1623752252
            case start_date = 2120079979
            case min_increase = 2437570383
            case allow_list = 2455929620
            case buy_now = 2643721309
            case fee_accounts = 3160431487
            case nifty_settlement = 3218572728
            case atomic = 3704294123
            case dutch = 3787478312
            case ending = 4203258855
        }
    }
    
    /// type AskSubscribeRequest = variant {
    ///   subscribe : record {
    ///     stake : record { principal; nat };
    ///     filter : opt record {
    ///       tokens : opt vec TokenSpecFilter;
    ///       token_ids : opt vec TokenIDFilter;
    ///     };
    ///   };
    ///   unsubscribe : record { principal; nat };
    /// };
    enum AskSubscribeRequest: Codable {
        case subscribe(stake: UnnamedType2, filter: UnnamedType3?)
        case unsubscribe(CandidPrincipal, BigUInt)
        
        enum CodingKeys: Int, CodingKey {
            case subscribe = 421006154
            case unsubscribe = 2663289297
        }
    }
    
    /// type AuctionConfig = record {
    ///   start_price : nat;
    ///   token : TokenSpec;
    ///   reserve : opt nat;
    ///   start_date : int;
    ///   min_increase : MinIncreaseType;
    ///   allow_list : opt vec principal;
    ///   buy_now : opt nat;
    ///   ending : variant {
    ///     date : int;
    ///     wait_for_quiet : record {
    ///       max : nat;
    ///       date : int;
    ///       fade : float64;
    ///       extension : nat64;
    ///     };
    ///   };
    /// };
    struct AuctionConfig: Codable {
        let start_price: BigUInt
        let token: TokenSpec
        let reserve: BigUInt?
        let start_date: BigInt
        let min_increase: MinIncreaseType
        let allow_list: [CandidPrincipal]?
        let buy_now: BigUInt?
        let ending: UnnamedType4
    }
    
    /// type AuctionStateShared = record {
    ///   status : variant { closed; open; not_started };
    ///   participants : vec record { principal; int };
    ///   token : TokenSpec__1;
    ///   current_bid_amount : nat;
    ///   winner : opt Account;
    ///   end_date : int;
    ///   current_config : BidConfigShared;
    ///   start_date : int;
    ///   wait_for_quiet_count : opt nat;
    ///   current_escrow : opt EscrowReceipt;
    ///   allow_list : opt vec record { principal; bool };
    ///   min_next_bid : nat;
    ///   config : PricingConfigShared__1;
    /// };
    struct AuctionStateShared: Codable {
        let status: UnnamedType5
        let participants: [UnnamedType6]
        let token: TokenSpec__1
        let current_bid_amount: BigUInt
        let winner: Account?
        let end_date: BigInt
        let current_config: BidConfigShared
        let start_date: BigInt
        let wait_for_quiet_count: BigUInt?
        let current_escrow: EscrowReceipt?
        let allow_list: [UnnamedType7]?
        let min_next_bid: BigUInt
        let config: PricingConfigShared__1
    }
    
    /// type BalanceResponse = record {
    ///   nfts : vec text;
    ///   offers : vec EscrowRecord__1;
    ///   sales : vec EscrowRecord__1;
    ///   stake : vec StakeRecord;
    ///   multi_canister : opt vec principal;
    ///   escrow : vec EscrowRecord__1;
    /// };
    struct BalanceResponse: Codable {
        let nfts: [String]
        let offers: [EscrowRecord__1]
        let sales: [EscrowRecord__1]
        let stake: [StakeRecord]
        let multi_canister: [CandidPrincipal]?
        let escrow: [EscrowRecord__1]
    }
    
    /// type BalanceResult = variant { ok : BalanceResponse; err : OrigynError };
    enum BalanceResult: Codable {
        case ok(BalanceResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type BearerResult = variant { ok : Account; err : OrigynError };
    enum BearerResult: Codable {
        case ok(Account)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type BidFeature = variant {
    ///   fee_schema : text;
    ///   broker : Account__1;
    ///   fee_accounts : FeeAccountsParams;
    /// };
    enum BidFeature: Codable {
        case fee_schema(String)
        case broker(Account__1)
        case fee_accounts(FeeAccountsParams)
        
        enum CodingKeys: Int, CodingKey {
            case fee_schema = 386492474
            case broker = 475510361
            case fee_accounts = 3160431487
        }
    }
    
    /// type BidRequest = record {
    ///   config : BidConfigShared;
    ///   escrow_record : EscrowRecord;
    /// };
    struct BidRequest: Codable {
        let config: BidConfigShared
        let escrow_record: EscrowRecord
    }
    
    /// type BidResponse = record {
    ///   token_id : text;
    ///   txn_type : variant {
    ///     escrow_deposit : record {
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     fee_deposit : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_network_updated : record {
    ///       network : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     escrow_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     canister_managers_updated : record {
    ///       managers : vec principal;
    ///       extensible : CandyShared;
    ///     };
    ///     auction_bid : record {
    ///       token : TokenSpec;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : text;
    ///     };
    ///     burn : record { from : opt Account__1; extensible : CandyShared };
    ///     data : record {
    ///       hash : opt vec nat8;
    ///       extensible : CandyShared;
    ///       data_dapp : opt text;
    ///       data_path : opt text;
    ///     };
    ///     sale_ended : record {
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       sale_id : opt text;
    ///     };
    ///     mint : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       sale : opt record { token : TokenSpec; amount : nat };
    ///       extensible : CandyShared;
    ///     };
    ///     royalty_paid : record {
    ///       tag : text;
    ///       token : TokenSpec;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///       receiver : Account__1;
    ///       sale_id : opt text;
    ///     };
    ///     extensible : CandyShared;
    ///     fee_deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       account : Account__1;
    ///       amount : nat;
    ///     };
    ///     owner_transfer : record {
    ///       to : Account__1;
    ///       from : Account__1;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_opened : record {
    ///       pricing : PricingConfigShared;
    ///       extensible : CandyShared;
    ///       sale_id : text;
    ///     };
    ///     canister_owner_updated : record {
    ///       owner : principal;
    ///       extensible : CandyShared;
    ///     };
    ///     sale_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       token_id : text;
    ///       trx_id : TransactionID;
    ///       seller : Account__1;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///     deposit_withdraw : record {
    ///       fee : nat;
    ///       token : TokenSpec;
    ///       trx_id : TransactionID;
    ///       extensible : CandyShared;
    ///       buyer : Account__1;
    ///       amount : nat;
    ///     };
    ///   };
    ///   timestamp : int;
    ///   index : nat;
    /// };
    struct BidResponse: Codable {
        let token_id: String
        let txn_type: UnnamedType9
        let timestamp: BigInt
        let index: BigUInt
    }
    
    /// type BlockType = record { url : text; block_type : text };
    struct BlockType: Codable {
        let url: String
        let block_type: String
    }
    
    /// type Data = variant {
    ///   Int : int;
    ///   Map : vec record { CandyShared; CandyShared };
    ///   Nat : nat;
    ///   Set : vec CandyShared;
    ///   Nat16 : nat16;
    ///   Nat32 : nat32;
    ///   Nat64 : nat64;
    ///   Blob : vec nat8;
    ///   Bool : bool;
    ///   Int8 : int8;
    ///   Ints : vec int;
    ///   Nat8 : nat8;
    ///   Nats : vec nat;
    ///   Text : text;
    ///   Bytes : vec nat8;
    ///   Int16 : int16;
    ///   Int32 : int32;
    ///   Int64 : int64;
    ///   Option : opt CandyShared;
    ///   Floats : vec float64;
    ///   Float : float64;
    ///   Principal : principal;
    ///   Array : vec CandyShared;
    ///   Class : vec PropertyShared;
    /// };
    indirect enum C_Data: Codable {
        case Int(BigInt)
        case Map([UnnamedType10])
        case Nat(BigUInt)
        case Set([CandyShared])
        case Nat16(UInt16)
        case Nat32(UInt32)
        case Nat64(UInt64)
        case Blob(Data)
        case Bool(Bool)
        case Int8(Int8)
        case Ints([BigInt])
        case Nat8(UInt8)
        case Nats([BigUInt])
        case Text(String)
        case Bytes(Data)
        case Int16(Int16)
        case Int32(Int32)
        case Int64(Int64)
        case Option(CandyShared?)
        case Floats([Double])
        case Float(Double)
        case Principal(CandidPrincipal)
        case Array([CandyShared])
        case Class([PropertyShared])
        
        enum CodingKeys: Int, CodingKey {
            case Int = 3654863
            case Map = 3850876
            case Nat = 3900609
            case Set = 4150146
            case Nat16 = 699867622
            case Nat32 = 699868064
            case Nat64 = 699868735
            case Blob = 737307005
            case Bool = 737456202
            case Int8 = 815034505
            case Ints = 815034564
            case Nat8 = 869835863
            case Nats = 869835922
            case Text = 936573133
            case Bytes = 1355118667
            case Int16 = 1364066676
            case Int32 = 1364067118
            case Int64 = 1364067789
            case Option = 1611614101
            case Floats = 1978308471
            case Float = 2512663932
            case Principal = 3017748110
            case Array = 3099385209
            case Class = 3682986008
        }
    }
    
    /// type CanisterLogFeature = variant {
    ///   filterMessageByContains;
    ///   filterMessageByRegex;
    /// };
    enum CanisterLogFeature: Codable {
        case filterMessageByContains
        case filterMessageByRegex
        
        enum CodingKeys: Int, CodingKey {
            case filterMessageByContains = 39249125
            case filterMessageByRegex = 1158138945
        }
    }
    
    /// type CanisterLogMessages = record {
    ///   data : vec LogMessagesData;
    ///   lastAnalyzedMessageTimeNanos : opt Nanos;
    /// };
    struct CanisterLogMessages: Codable {
        let data: [LogMessagesData]
        let lastAnalyzedMessageTimeNanos: Nanos?
    }
    
    /// type CanisterLogMessagesInfo = record {
    ///   features : vec opt CanisterLogFeature;
    ///   lastTimeNanos : opt Nanos;
    ///   count : nat32;
    ///   firstTimeNanos : opt Nanos;
    /// };
    struct CanisterLogMessagesInfo: Codable {
        let features: [CanisterLogFeature?]
        let lastTimeNanos: Nanos?
        let count: UInt32
        let firstTimeNanos: Nanos?
    }
    
    /// type CanisterLogRequest = variant {
    ///   getMessagesInfo;
    ///   getMessages : GetLogMessagesParameters;
    ///   getLatestMessages : GetLatestLogMessagesParameters;
    /// };
    enum CanisterLogRequest: Codable {
        case getMessagesInfo
        case getMessages(GetLogMessagesParameters)
        case getLatestMessages(GetLatestLogMessagesParameters)
        
        enum CodingKeys: Int, CodingKey {
            case getMessagesInfo = 1309075728
            case getMessages = 1525783426
            case getLatestMessages = 2844223593
        }
    }
    
    /// type CanisterLogResponse = variant {
    ///   messagesInfo : CanisterLogMessagesInfo;
    ///   messages : CanisterLogMessages;
    /// };
    enum CanisterLogResponse: Codable {
        case messagesInfo(CanisterLogMessagesInfo)
        case messages(CanisterLogMessages)
        
        enum CodingKeys: Int, CodingKey {
            case messagesInfo = 723293018
            case messages = 889051340
        }
    }
    
    /// type CanisterMetrics = record { data : CanisterMetricsData };
    struct CanisterMetrics: Codable {
        let data: CanisterMetricsData
    }
    
    /// type CanisterMetricsData = variant {
    ///   hourly : vec HourlyMetricsData;
    ///   daily : vec DailyMetricsData;
    /// };
    enum CanisterMetricsData: Codable {
        case hourly([HourlyMetricsData])
        case daily([DailyMetricsData])
        
        enum CodingKeys: Int, CodingKey {
            case hourly = 3427057841
            case daily = 3565141977
        }
    }
    
    /// type ChunkContent = variant {
    ///   remote : record { args : ChunkRequest; canister : principal };
    ///   chunk : record {
    ///     total_chunks : nat;
    ///     content : vec nat8;
    ///     storage_allocation : AllocationRecordStable;
    ///     current_chunk : opt nat;
    ///   };
    /// };
    enum ChunkContent: Codable {
        case remote(args: ChunkRequest, canister: CandidPrincipal)
        case chunk(total_chunks: BigUInt, content: Data, storage_allocation: AllocationRecordStable, current_chunk: BigUInt?)
        
        enum CodingKeys: Int, CodingKey {
            case remote = 76061318
            case chunk = 1170392685
        }
    }
    
    /// type ChunkRequest = record {
    ///   token_id : text;
    ///   chunk : opt nat;
    ///   library_id : text;
    /// };
    struct ChunkRequest: Codable {
        let token_id: String
        let chunk: BigUInt?
        let library_id: String
    }
    
    /// type ChunkResult = variant { ok : ChunkContent; err : OrigynError };
    enum ChunkResult: Codable {
        case ok(ChunkContent)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type CollectionInfo = record {
    ///   multi_canister_count : opt nat;
    ///   managers : opt vec principal;
    ///   owner : opt principal;
    ///   metadata : opt CandyShared;
    ///   logo : opt text;
    ///   name : opt text;
    ///   network : opt principal;
    ///   created_at : opt nat64;
    ///   fields : opt vec record { text; opt nat; opt nat };
    ///   upgraded_at : opt nat64;
    ///   token_ids_count : opt nat;
    ///   available_space : opt nat;
    ///   multi_canister : opt vec principal;
    ///   token_ids : opt vec text;
    ///   transaction_count : opt nat;
    ///   unique_holders : opt nat;
    ///   total_supply : opt nat;
    ///   symbol : opt text;
    ///   allocated_storage : opt nat;
    /// };
    struct CollectionInfo: Codable {
        let multi_canister_count: BigUInt?
        let managers: [CandidPrincipal]?
        let owner: CandidPrincipal?
        let metadata: CandyShared?
        let logo: String?
        let name: String?
        let network: CandidPrincipal?
        let created_at: UInt64?
        let fields: [UnnamedType11]?
        let upgraded_at: UInt64?
        let token_ids_count: BigUInt?
        let available_space: BigUInt?
        let multi_canister: [CandidPrincipal]?
        let token_ids: [String]?
        let transaction_count: BigUInt?
        let unique_holders: BigUInt?
        let total_supply: BigUInt?
        let symbol: String?
        let allocated_storage: BigUInt?
    }
    
    /// type CollectionResult = variant { ok : CollectionInfo; err : OrigynError };
    enum CollectionResult: Codable {
        case ok(CollectionInfo)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type DIP721BoolResult = variant { Ok : bool; Err : NftError };
    enum DIP721BoolResult: Codable {
        case Ok(Bool)
        case Err(NftError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// type DIP721Metadata = record {
    ///   logo : opt text;
    ///   name : opt text;
    ///   created_at : nat64;
    ///   upgraded_at : nat64;
    ///   custodians : vec principal;
    ///   symbol : opt text;
    /// };
    struct DIP721Metadata: Codable {
        let logo: String?
        let name: String?
        let created_at: UInt64
        let upgraded_at: UInt64
        let custodians: [CandidPrincipal]
        let symbol: String?
    }
    
    /// type DIP721NatResult = variant { Ok : nat; Err : NftError };
    enum DIP721NatResult: Codable {
        case Ok(BigUInt)
        case Err(NftError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// type DIP721Stats = record {
    ///   cycles : nat;
    ///   total_transactions : nat;
    ///   total_unique_holders : nat;
    ///   total_supply : nat;
    /// };
    struct DIP721Stats: Codable {
        let cycles: BigUInt
        let total_transactions: BigUInt
        let total_unique_holders: BigUInt
        let total_supply: BigUInt
    }
    
    /// type DIP721SupportedInterface = variant {
    ///   Burn;
    ///   Mint;
    ///   Approval;
    ///   TransactionHistory;
    /// };
    enum DIP721SupportedInterface: Codable {
        case Burn
        case Mint
        case Approval
        case TransactionHistory
        
        enum CodingKeys: Int, CodingKey {
            case Burn = 737755247
            case Mint = 859142850
            case Approval = 1821509411
            case TransactionHistory = 2765436726
        }
    }
    
    /// type DIP721TokenMetadata = variant { Ok : TokenMetadata; Err : NftError };
    enum DIP721TokenMetadata: Codable {
        case Ok(TokenMetadata)
        case Err(NftError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// type DIP721TokensListMetadata = variant { Ok : vec nat; Err : NftError };
    enum DIP721TokensListMetadata: Codable {
        case Ok([BigUInt])
        case Err(NftError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// type DIP721TokensMetadata = variant { Ok : vec TokenMetadata; Err : NftError };
    enum DIP721TokensMetadata: Codable {
        case Ok([TokenMetadata])
        case Err(NftError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// type DailyMetricsData = record {
    ///   updateCalls : nat64;
    ///   canisterHeapMemorySize : NumericEntity;
    ///   canisterCycles : NumericEntity;
    ///   canisterMemorySize : NumericEntity;
    ///   timeMillis : int;
    /// };
    struct DailyMetricsData: Codable {
        let updateCalls: UInt64
        let canisterHeapMemorySize: NumericEntity
        let canisterCycles: NumericEntity
        let canisterMemorySize: NumericEntity
        let timeMillis: BigInt
    }
    
    /// type DataCertificate = record { certificate : vec nat8; hash_tree : vec nat8 };
    struct DataCertificate: Codable {
        let certificate: Data
        let hash_tree: Data
    }
    
    /// type DepositDetail = record {
    ///   token : TokenSpec__1;
    ///   trx_id : opt TransactionID__1;
    ///   seller : Account;
    ///   buyer : Account;
    ///   amount : nat;
    ///   sale_id : opt text;
    /// };
    struct DepositDetail: Codable {
        let token: TokenSpec__1
        let trx_id: TransactionID__1?
        let seller: Account
        let buyer: Account
        let amount: BigUInt
        let sale_id: String?
    }
    
    /// type DepositWithdrawDescription = record {
    ///   token : TokenSpec__1;
    ///   withdraw_to : Account;
    ///   buyer : Account;
    ///   amount : nat;
    /// };
    struct DepositWithdrawDescription: Codable {
        let token: TokenSpec__1
        let withdraw_to: Account
        let buyer: Account
        let amount: BigUInt
    }
    
    /// type DistributeSaleRequest = record { seller : opt Account };
    struct DistributeSaleRequest: Codable {
        let seller: Account?
    }
    
    /// type DutchParams = record {
    ///   time_unit : variant { day : nat; hour : nat; minute : nat };
    ///   decay_type : variant { flat : nat; percent : float64 };
    /// };
    struct DutchParams: Codable {
        let time_unit: UnnamedType13
        let decay_type: UnnamedType14
    }
    
    /// type EXTBalanceRequest = record { token : EXTTokenIdentifier; user : EXTUser };
    struct EXTBalanceRequest: Codable {
        let token: EXTTokenIdentifier
        let user: EXTUser
    }
    
    /// type EXTBalanceResult = variant { ok : EXTBalance; err : EXTCommonError };
    enum EXTBalanceResult: Codable {
        case ok(EXTBalance)
        case err(EXTCommonError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type EXTBearerResult = variant {
    ///   ok : EXTAccountIdentifier;
    ///   err : EXTCommonError;
    /// };
    enum EXTBearerResult: Codable {
        case ok(EXTAccountIdentifier)
        case err(EXTCommonError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type EXTCommonError = variant {
    ///   InvalidToken : EXTTokenIdentifier;
    ///   Other : text;
    /// };
    enum EXTCommonError: Codable {
        case InvalidToken(EXTTokenIdentifier)
        case Other(String)
        
        enum CodingKeys: Int, CodingKey {
            case InvalidToken = 2173912226
            case Other = 3382957744
        }
    }
    
    /// type EXTMetadata = variant {
    ///   fungible : record {
    ///     decimals : nat8;
    ///     metadata : opt vec nat8;
    ///     name : text;
    ///     symbol : text;
    ///   };
    ///   nonfungible : record { metadata : opt vec nat8 };
    /// };
    enum EXTMetadata: Codable {
        case fungible(decimals: UInt8, metadata: Data?, name: String, symbol: String)
        case nonfungible(metadata: Data?)
        
        enum CodingKeys: Int, CodingKey {
            case fungible = 1520587226
            case nonfungible = 3191439335
        }
    }
    
    /// type EXTMetadataResult = variant { ok : EXTMetadata; err : EXTCommonError };
    enum EXTMetadataResult: Codable {
        case ok(EXTMetadata)
        case err(EXTCommonError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type EXTTokensResponse = record {
    ///   nat32;
    ///   opt record { locked : opt int; seller : principal; price : nat64 };
    ///   opt vec nat8;
    /// };
    struct EXTTokensResponse: Codable {
        let _0: UInt32
        let _1: UnnamedType15?
        let _2: Data?
        
        init(_ _0: UInt32, _ _1: UnnamedType15?, _ _2: Data?) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
        }
    }
    
    /// type EXTTokensResult = variant {
    ///   ok : vec EXTTokensResponse;
    ///   err : EXTCommonError;
    /// };
    enum EXTTokensResult: Codable {
        case ok([EXTTokensResponse])
        case err(EXTCommonError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type EXTTransferRequest = record {
    ///   to : EXTUser;
    ///   token : EXTTokenIdentifier;
    ///   notify : bool;
    ///   from : EXTUser;
    ///   memo : EXTMemo;
    ///   subaccount : opt EXTSubAccount;
    ///   amount : EXTBalance;
    /// };
    struct EXTTransferRequest: Codable {
        let to: EXTUser
        let token: EXTTokenIdentifier
        let notify: Bool
        let from: EXTUser
        let memo: EXTMemo
        let subaccount: EXTSubAccount?
        let amount: EXTBalance
    }
    
    /// type EXTTransferResponse = variant {
    ///   ok : EXTBalance;
    ///   err : variant {
    ///     CannotNotify : EXTAccountIdentifier;
    ///     InsufficientBalance;
    ///     InvalidToken : EXTTokenIdentifier;
    ///     Rejected;
    ///     Unauthorized : EXTAccountIdentifier;
    ///     Other : text;
    ///   };
    /// };
    enum EXTTransferResponse: Codable {
        case ok(EXTBalance)
        case err(UnnamedType16)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type EXTUser = variant { "principal" : principal; address : text };
    enum EXTUser: Codable {
        case principal(CandidPrincipal)
        case address(String)
        
        enum CodingKeys: Int, CodingKey {
            case principal = 302796462
            case address = 2634772916
        }
    }
    
    /// type EndingType = variant { date : int; timeout : nat };
    enum EndingType: Codable {
        case date(BigInt)
        case timeout(BigUInt)
        
        enum CodingKeys: Int, CodingKey {
            case date = 1113806382
            case timeout = 3640072865
        }
    }
    
    /// type Errors = variant {
    ///   nyi;
    ///   storage_configuration_error;
    ///   escrow_withdraw_payment_failed;
    ///   token_not_found;
    ///   owner_not_found;
    ///   content_not_found;
    ///   auction_ended;
    ///   out_of_range;
    ///   sale_id_does_not_match;
    ///   sale_not_found;
    ///   kyc_fail;
    ///   item_not_owned;
    ///   property_not_found;
    ///   validate_trx_wrong_host;
    ///   withdraw_too_large;
    ///   content_not_deserializable;
    ///   bid_too_low;
    ///   validate_deposit_wrong_amount;
    ///   existing_sale_found;
    ///   noop;
    ///   asset_mismatch;
    ///   escrow_cannot_be_removed;
    ///   deposit_burned;
    ///   cannot_restage_minted_token;
    ///   cannot_find_status_in_metadata;
    ///   receipt_data_mismatch;
    ///   validate_deposit_failed;
    ///   unreachable;
    ///   unauthorized_access;
    ///   item_already_minted;
    ///   no_escrow_found;
    ///   escrow_owner_not_the_owner;
    ///   improper_interface;
    ///   app_id_not_found;
    ///   token_non_transferable;
    ///   kyc_error;
    ///   sale_not_over;
    ///   escrow_not_large_enough;
    ///   update_class_error;
    ///   malformed_metadata;
    ///   token_id_mismatch;
    ///   id_not_found_in_metadata;
    ///   auction_not_started;
    ///   low_fee_balance;
    ///   library_not_found;
    ///   attempt_to_stage_system_data;
    ///   no_fee_accounts_provided;
    ///   validate_deposit_wrong_buyer;
    ///   not_enough_storage;
    ///   sales_withdraw_payment_failed;
    /// };
    enum Errors: Codable {
        case nyi
        case storage_configuration_error
        case escrow_withdraw_payment_failed
        case token_not_found
        case owner_not_found
        case content_not_found
        case auction_ended
        case out_of_range
        case sale_id_does_not_match
        case sale_not_found
        case kyc_fail
        case item_not_owned
        case property_not_found
        case validate_trx_wrong_host
        case withdraw_too_large
        case content_not_deserializable
        case bid_too_low
        case validate_deposit_wrong_amount
        case existing_sale_found
        case noop
        case asset_mismatch
        case escrow_cannot_be_removed
        case deposit_burned
        case cannot_restage_minted_token
        case cannot_find_status_in_metadata
        case receipt_data_mismatch
        case validate_deposit_failed
        case unreachable
        case unauthorized_access
        case item_already_minted
        case no_escrow_found
        case escrow_owner_not_the_owner
        case improper_interface
        case app_id_not_found
        case token_non_transferable
        case kyc_error
        case sale_not_over
        case escrow_not_large_enough
        case update_class_error
        case malformed_metadata
        case token_id_mismatch
        case id_not_found_in_metadata
        case auction_not_started
        case low_fee_balance
        case library_not_found
        case attempt_to_stage_system_data
        case no_fee_accounts_provided
        case validate_deposit_wrong_buyer
        case not_enough_storage
        case sales_withdraw_payment_failed
        
        enum CodingKeys: Int, CodingKey {
            case nyi = 5497278
            case storage_configuration_error = 75494907
            case escrow_withdraw_payment_failed = 92101489
            case token_not_found = 120423120
            case owner_not_found = 141108362
            case content_not_found = 189062416
            case auction_ended = 246191806
            case out_of_range = 258969190
            case sale_id_does_not_match = 346009535
            case sale_not_found = 449036254
            case kyc_fail = 467034792
            case item_not_owned = 467582797
            case property_not_found = 514921260
            case validate_trx_wrong_host = 572685800
            case withdraw_too_large = 674238939
            case content_not_deserializable = 724885362
            case bid_too_low = 899969383
            case validate_deposit_wrong_amount = 1018224692
            case existing_sale_found = 1085269950
            case noop = 1225397154
            case asset_mismatch = 1244521405
            case escrow_cannot_be_removed = 1268081638
            case deposit_burned = 1294638191
            case cannot_restage_minted_token = 1423918155
            case cannot_find_status_in_metadata = 1754103174
            case receipt_data_mismatch = 1832107836
            case validate_deposit_failed = 1881052295
            case unreachable = 2132396308
            case unauthorized_access = 2224785295
            case item_already_minted = 2272551284
            case no_escrow_found = 2454315590
            case escrow_owner_not_the_owner = 2602586483
            case improper_interface = 2690204718
            case app_id_not_found = 2826145744
            case token_non_transferable = 3057215293
            case kyc_error = 3080508350
            case sale_not_over = 3145235256
            case escrow_not_large_enough = 3258336922
            case update_class_error = 3351913163
            case malformed_metadata = 3412721715
            case token_id_mismatch = 3448184556
            case id_not_found_in_metadata = 3704461692
            case auction_not_started = 3740016537
            case low_fee_balance = 3797351288
            case library_not_found = 3991141714
            case attempt_to_stage_system_data = 4007920423
            case no_fee_accounts_provided = 4047017829
            case validate_deposit_wrong_buyer = 4107545175
            case not_enough_storage = 4144306008
            case sales_withdraw_payment_failed = 4250305400
        }
    }
    
    /// type EscrowReceipt = record {
    ///   token : TokenSpec;
    ///   token_id : text;
    ///   seller : Account__1;
    ///   buyer : Account__1;
    ///   amount : nat;
    /// };
    struct EscrowReceipt: Codable {
        let token: TokenSpec
        let token_id: String
        let seller: Account__1
        let buyer: Account__1
        let amount: BigUInt
    }
    
    /// type EscrowRecord = record {
    ///   token : TokenSpec__2;
    ///   token_id : text;
    ///   seller : Account__2;
    ///   lock_to_date : opt int;
    ///   buyer : Account__2;
    ///   amount : nat;
    ///   sale_id : opt text;
    ///   account_hash : opt vec nat8;
    /// };
    struct EscrowRecord: Codable {
        let token: TokenSpec__2
        let token_id: String
        let seller: Account__2
        let lock_to_date: BigInt?
        let buyer: Account__2
        let amount: BigUInt
        let sale_id: String?
        let account_hash: Data?
    }
    
    /// type EscrowRecord__1 = record {
    ///   token : TokenSpec__1;
    ///   token_id : text;
    ///   seller : Account;
    ///   lock_to_date : opt int;
    ///   buyer : Account;
    ///   amount : nat;
    ///   sale_id : opt text;
    ///   account_hash : opt vec nat8;
    /// };
    struct EscrowRecord__1: Codable {
        let token: TokenSpec__1
        let token_id: String
        let seller: Account
        let lock_to_date: BigInt?
        let buyer: Account
        let amount: BigUInt
        let sale_id: String?
        let account_hash: Data?
    }
    
    /// type EscrowRequest = record {
    ///   token_id : text;
    ///   deposit : DepositDetail;
    ///   lock_to_date : opt int;
    /// };
    struct EscrowRequest: Codable {
        let token_id: String
        let deposit: DepositDetail
        let lock_to_date: BigInt?
    }
    
    /// type EscrowResponse = record {
    ///   balance : nat;
    ///   receipt : EscrowReceipt;
    ///   transaction : TransactionRecord;
    /// };
    struct EscrowResponse: Codable {
        let balance: BigUInt
        let receipt: EscrowReceipt
        let transaction: TransactionRecord
    }
    
    /// type FeeDepositRequest = record { token : TokenSpec__1; account : Account };
    struct FeeDepositRequest: Codable {
        let token: TokenSpec__1
        let account: Account
    }
    
    /// type FeeDepositResponse = record {
    ///   balance : nat;
    ///   transaction : TransactionRecord;
    /// };
    struct FeeDepositResponse: Codable {
        let balance: BigUInt
        let transaction: TransactionRecord
    }
    
    /// type FeeDepositWithdrawDescription = record {
    ///   status : variant { locked : record { sale_id : text }; unlocked };
    ///   token : TokenSpec__1;
    ///   withdraw_to : Account;
    ///   account : Account;
    ///   amount : nat;
    /// };
    struct FeeDepositWithdrawDescription: Codable {
        let status: UnnamedType17
        let token: TokenSpec__1
        let withdraw_to: Account
        let account: Account
        let amount: BigUInt
    }
    
    /// type GenericValue = variant {
    ///   Nat64Content : nat64;
    ///   Nat32Content : nat32;
    ///   BoolContent : bool;
    ///   Nat8Content : nat8;
    ///   Int64Content : int64;
    ///   IntContent : int;
    ///   NatContent : nat;
    ///   Nat16Content : nat16;
    ///   Int32Content : int32;
    ///   Int8Content : int8;
    ///   FloatContent : float64;
    ///   Int16Content : int16;
    ///   BlobContent : vec nat8;
    ///   NestedContent : Vec;
    ///   Principal : principal;
    ///   TextContent : text;
    /// };
    enum GenericValue: Codable {
        case Nat64Content(UInt64)
        case Nat32Content(UInt32)
        case BoolContent(Bool)
        case Nat8Content(UInt8)
        case Int64Content(Int64)
        case IntContent(BigInt)
        case NatContent(BigUInt)
        case Nat16Content(UInt16)
        case Int32Content(Int32)
        case Int8Content(Int8)
        case FloatContent(Double)
        case Int16Content(Int16)
        case BlobContent(Data)
        case NestedContent(Vec)
        case Principal(CandidPrincipal)
        case TextContent(String)
        
        enum CodingKeys: Int, CodingKey {
            case Nat64Content = 38560954
            case Nat32Content = 387138937
            case BoolContent = 408879631
            case Nat8Content = 523327906
            case Int64Content = 1155183340
            case IntContent = 1251719210
            case NatContent = 1439545976
            case Nat16Content = 1442462707
            case Int32Content = 1503761323
            case Int8Content = 1587632048
            case FloatContent = 2006214429
            case Int16Content = 2559085093
            case BlobContent = 2609325372
            case NestedContent = 2928718562
            case Principal = 3017748110
            case TextContent = 3643416556
        }
    }
    
    /// type GetArchivesArgs = record { from : opt principal };
    struct GetArchivesArgs: Codable {
        let from: CandidPrincipal?
    }
    
    /// type GetArchivesResultItem = record {
    ///   end : nat;
    ///   canister_id : principal;
    ///   start : nat;
    /// };
    struct GetArchivesResultItem: Codable {
        let end: BigUInt
        let canister_id: CandidPrincipal
        let start: BigUInt
    }
    
    /// type GetLatestLogMessagesParameters = record {
    ///   upToTimeNanos : opt Nanos;
    ///   count : nat32;
    ///   filter : opt GetLogMessagesFilter;
    /// };
    struct GetLatestLogMessagesParameters: Codable {
        let upToTimeNanos: Nanos?
        let count: UInt32
        let filter: GetLogMessagesFilter?
    }
    
    /// type GetLogMessagesFilter = record {
    ///   analyzeCount : nat32;
    ///   messageRegex : opt text;
    ///   messageContains : opt text;
    /// };
    struct GetLogMessagesFilter: Codable {
        let analyzeCount: UInt32
        let messageRegex: String?
        let messageContains: String?
    }
    
    /// type GetLogMessagesParameters = record {
    ///   count : nat32;
    ///   filter : opt GetLogMessagesFilter;
    ///   fromTimeNanos : opt Nanos;
    /// };
    struct GetLogMessagesParameters: Codable {
        let count: UInt32
        let filter: GetLogMessagesFilter?
        let fromTimeNanos: Nanos?
    }
    
    /// type GetMetricsParameters = record {
    ///   dateToMillis : nat;
    ///   granularity : MetricsGranularity;
    ///   dateFromMillis : nat;
    /// };
    struct GetMetricsParameters: Codable {
        let dateToMillis: BigUInt
        let granularity: MetricsGranularity
        let dateFromMillis: BigUInt
    }
    
    /// type GetTransactionsResult = record {
    ///   log_length : nat;
    ///   blocks : vec record { id : nat; block : Value__1 };
    ///   archived_blocks : vec ArchivedTransactionResponse;
    /// };
    struct GetTransactionsResult: Codable {
        let log_length: BigUInt
        let blocks: [UnnamedType18]
        let archived_blocks: [ArchivedTransactionResponse]
    }
    
    /// type GovernanceRequest = variant {
    ///   update_system_var : record { key : text; val : CandyShared; token_id : text };
    ///   clear_shared_wallets : text;
    /// };
    enum GovernanceRequest: Codable {
        case update_system_var(key: String, val: CandyShared, token_id: String)
        case clear_shared_wallets(String)
        
        enum CodingKeys: Int, CodingKey {
            case update_system_var = 1435516941
            case clear_shared_wallets = 3207328050
        }
    }
    
    /// type GovernanceResponse = variant {
    ///   update_system_var : bool;
    ///   clear_shared_wallets : bool;
    /// };
    enum GovernanceResponse: Codable {
        case update_system_var(Bool)
        case clear_shared_wallets(Bool)
        
        enum CodingKeys: Int, CodingKey {
            case update_system_var = 1435516941
            case clear_shared_wallets = 3207328050
        }
    }
    
    /// type GovernanceResult = variant { ok : GovernanceResponse; err : OrigynError };
    enum GovernanceResult: Codable {
        case ok(GovernanceResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type HTTPResponse = record {
    ///   body : vec nat8;
    ///   headers : vec HeaderField;
    ///   streaming_strategy : opt StreamingStrategy;
    ///   status_code : nat16;
    /// };
    struct HTTPResponse: Codable {
        let body: Data
        let headers: [HeaderField]
        let streaming_strategy: StreamingStrategy?
        let status_code: UInt16
    }
    
    /// type HeaderField = record { text; text };
    struct HeaderField: Codable {
        let _0: String
        let _1: String
        
        init(_ _0: String, _ _1: String) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    /// type HistoryResult = variant { ok : vec TransactionRecord; err : OrigynError };
    enum HistoryResult: Codable {
        case ok([TransactionRecord])
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type HourlyMetricsData = record {
    ///   updateCalls : UpdateCallsAggregatedData;
    ///   canisterHeapMemorySize : CanisterHeapMemoryAggregatedData;
    ///   canisterCycles : CanisterCyclesAggregatedData;
    ///   canisterMemorySize : CanisterMemoryAggregatedData;
    ///   timeMillis : int;
    /// };
    struct HourlyMetricsData: Codable {
        let updateCalls: UpdateCallsAggregatedData
        let canisterHeapMemorySize: CanisterHeapMemoryAggregatedData
        let canisterCycles: CanisterCyclesAggregatedData
        let canisterMemorySize: CanisterMemoryAggregatedData
        let timeMillis: BigInt
    }
    
    /// type HttpRequest = record {
    ///   url : text;
    ///   method : text;
    ///   body : vec nat8;
    ///   headers : vec HeaderField;
    /// };
    struct HttpRequest: Codable {
        let url: String
        let method: String
        let body: Data
        let headers: [HeaderField]
    }
    
    /// type ICTokenSpec = record {
    ///   id : opt nat;
    ///   fee : opt nat;
    ///   decimals : nat;
    ///   canister : principal;
    ///   standard : variant { ICRC1; EXTFungible; DIP20; Other : CandyShared; Ledger };
    ///   symbol : text;
    /// };
    struct ICTokenSpec: Codable {
        let id: BigUInt?
        let fee: BigUInt?
        let decimals: BigUInt
        let canister: CandidPrincipal
        let standard: UnnamedType19
        let symbol: String
    }
    
    /// type IndexType = variant { Stable; StableTyped; Managed };
    enum IndexType: Codable {
        case Stable
        case StableTyped
        case Managed
        
        enum CodingKeys: Int, CodingKey {
            case Stable = 981641947
            case StableTyped = 1471544207
            case Managed = 3776100927
        }
    }
    
    /// type InstantFeature = variant {
    ///   fee_schema : text;
    ///   fee_accounts : FeeAccountsParams;
    /// };
    enum InstantFeature: Codable {
        case fee_schema(String)
        case fee_accounts(FeeAccountsParams)
        
        enum CodingKeys: Int, CodingKey {
            case fee_schema = 386492474
            case fee_accounts = 3160431487
        }
    }
    
    /// type LogMessagesData = record {
    ///   data : Data;
    ///   timeNanos : Nanos;
    ///   message : text;
    ///   caller : Caller;
    /// };
    struct LogMessagesData: Codable {
        let data: C_Data
        let timeNanos: Nanos
        let message: String
        let caller: Caller
    }
    
    /// type ManageCollectionCommand = variant {
    ///   UpdateOwner : principal;
    ///   UpdateManagers : vec principal;
    ///   UpdateMetadata : record { text; opt CandyShared; bool };
    ///   UpdateAnnounceCanister : opt principal;
    ///   UpdateNetwork : opt principal;
    ///   UpdateSymbol : opt text;
    ///   UpdateLogo : opt text;
    ///   UpdateName : opt text;
    /// };
    enum ManageCollectionCommand: Codable {
        case UpdateOwner(CandidPrincipal)
        case UpdateManagers([CandidPrincipal])
        case UpdateMetadata(String, CandyShared?, Bool)
        case UpdateAnnounceCanister(CandidPrincipal?)
        case UpdateNetwork(CandidPrincipal?)
        case UpdateSymbol(String?)
        case UpdateLogo(String?)
        case UpdateName(String?)
        
        enum CodingKeys: Int, CodingKey {
            case UpdateOwner = 37853514
            case UpdateManagers = 354292911
            case UpdateMetadata = 530149048
            case UpdateAnnounceCanister = 1185171001
            case UpdateNetwork = 1830517125
            case UpdateSymbol = 3065225825
            case UpdateLogo = 4145909300
            case UpdateName = 4167393556
        }
    }
    
    /// type ManageSaleRequest = variant {
    ///   bid : BidRequest;
    ///   escrow_deposit : EscrowRequest;
    ///   fee_deposit : FeeDepositRequest;
    ///   recognize_escrow : EscrowRequest;
    ///   withdraw : WithdrawRequest;
    ///   ask_subscribe : AskSubscribeRequest;
    ///   end_sale : text;
    ///   refresh_offers : opt Account;
    ///   distribute_sale : DistributeSaleRequest;
    ///   open_sale : text;
    /// };
    enum ManageSaleRequest: Codable {
        case bid(BidRequest)
        case escrow_deposit(EscrowRequest)
        case fee_deposit(FeeDepositRequest)
        case recognize_escrow(EscrowRequest)
        case withdraw(WithdrawRequest)
        case ask_subscribe(AskSubscribeRequest)
        case end_sale(String)
        case refresh_offers(Account?)
        case distribute_sale(DistributeSaleRequest)
        case open_sale(String)
        
        enum CodingKeys: Int, CodingKey {
            case bid = 4896957
            case escrow_deposit = 53258980
            case fee_deposit = 268167461
            case recognize_escrow = 363439702
            case withdraw = 709041418
            case ask_subscribe = 1218389892
            case end_sale = 1781448875
            case refresh_offers = 1987050619
            case distribute_sale = 2328546725
            case open_sale = 3746995804
        }
    }
    
    /// type ManageSaleResponse = variant {
    ///   bid : BidResponse;
    ///   escrow_deposit : EscrowResponse;
    ///   fee_deposit : FeeDepositResponse;
    ///   recognize_escrow : RecognizeEscrowResponse;
    ///   withdraw : WithdrawResponse;
    ///   ask_subscribe : AskSubscribeResponse;
    ///   end_sale : EndSaleResponse;
    ///   refresh_offers : vec EscrowRecord__1;
    ///   distribute_sale : DistributeSaleResponse;
    ///   open_sale : bool;
    /// };
    enum ManageSaleResponse: Codable {
        case bid(BidResponse)
        case escrow_deposit(EscrowResponse)
        case fee_deposit(FeeDepositResponse)
        case recognize_escrow(RecognizeEscrowResponse)
        case withdraw(WithdrawResponse)
        case ask_subscribe(AskSubscribeResponse)
        case end_sale(EndSaleResponse)
        case refresh_offers([EscrowRecord__1])
        case distribute_sale(DistributeSaleResponse)
        case open_sale(Bool)
        
        enum CodingKeys: Int, CodingKey {
            case bid = 4896957
            case escrow_deposit = 53258980
            case fee_deposit = 268167461
            case recognize_escrow = 363439702
            case withdraw = 709041418
            case ask_subscribe = 1218389892
            case end_sale = 1781448875
            case refresh_offers = 1987050619
            case distribute_sale = 2328546725
            case open_sale = 3746995804
        }
    }
    
    /// type ManageSaleResult = variant { ok : ManageSaleResponse; err : OrigynError };
    enum ManageSaleResult: Codable {
        case ok(ManageSaleResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type ManageStorageRequest = variant {
    ///   add_storage_canisters : vec record {
    ///     principal;
    ///     nat;
    ///     record { nat; nat; nat };
    ///   };
    ///   configure_storage : variant { stableBtree : opt nat; heap : opt nat };
    /// };
    enum ManageStorageRequest: Codable {
        case add_storage_canisters([UnnamedType21])
        case configure_storage(UnnamedType22)
        
        enum CodingKeys: Int, CodingKey {
            case add_storage_canisters = 2947008074
            case configure_storage = 3854731426
        }
    }
    
    /// type ManageStorageResponse = variant {
    ///   add_storage_canisters : record { nat; nat };
    ///   configure_storage : record { nat; nat };
    /// };
    enum ManageStorageResponse: Codable {
        case add_storage_canisters(BigUInt, BigUInt)
        case configure_storage(BigUInt, BigUInt)
        
        enum CodingKeys: Int, CodingKey {
            case add_storage_canisters = 2947008074
            case configure_storage = 3854731426
        }
    }
    
    /// type ManageStorageResult = variant {
    ///   ok : ManageStorageResponse;
    ///   err : OrigynError;
    /// };
    enum ManageStorageResult: Codable {
        case ok(ManageStorageResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type MarketTransferRequest = record {
    ///   token_id : text;
    ///   sales_config : SalesConfig;
    /// };
    struct MarketTransferRequest: Codable {
        let token_id: String
        let sales_config: SalesConfig
    }
    
    /// type MarketTransferResult = variant {
    ///   ok : MarketTransferRequestReponse;
    ///   err : OrigynError;
    /// };
    enum MarketTransferResult: Codable {
        case ok(MarketTransferRequestReponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type MetricsGranularity = variant { hourly; daily };
    enum MetricsGranularity: Codable {
        case hourly
        case daily
        
        enum CodingKeys: Int, CodingKey {
            case hourly = 3427057841
            case daily = 3565141977
        }
    }
    
    /// type MinIncreaseType = variant { amount : nat; percentage : float64 };
    enum MinIncreaseType: Codable {
        case amount(BigUInt)
        case percentage(Double)
        
        enum CodingKeys: Int, CodingKey {
            case amount = 3573748184
            case percentage = 3962344218
        }
    }
    
    /// type NFTBackupChunk = record {
    ///   sales_balances : StableSalesBalances;
    ///   offers : StableOffers;
    ///   collection_data : StableCollectionData;
    ///   nft_ledgers : StableNftLedger;
    ///   canister : principal;
    ///   allocations : vec record { record { text; text }; AllocationRecordStable };
    ///   nft_sales : vec record { text; SaleStatusShared };
    ///   buckets : vec record { principal; StableBucketData };
    ///   escrow_balances : StableEscrowBalances;
    /// };
    struct NFTBackupChunk: Codable {
        let sales_balances: StableSalesBalances
        let offers: StableOffers
        let collection_data: StableCollectionData
        let nft_ledgers: StableNftLedger
        let canister: CandidPrincipal
        let allocations: [UnnamedType23]
        let nft_sales: [UnnamedType24]
        let buckets: [UnnamedType25]
        let escrow_balances: StableEscrowBalances
    }
    
    /// type NFTInfoResult = variant { ok : NFTInfoStable; err : OrigynError };
    enum NFTInfoResult: Codable {
        case ok(NFTInfoStable)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type NFTInfoStable = record {
    ///   metadata : CandyShared;
    ///   current_sale : opt SaleStatusShared;
    /// };
    struct NFTInfoStable: Codable {
        let metadata: CandyShared
        let current_sale: SaleStatusShared?
    }
    
    /// type NFTUpdateRequest = variant {
    ///   update : record {
    ///     token_id : text;
    ///     update : UpdateRequestShared;
    ///     app_id : text;
    ///   };
    ///   replace : record { token_id : text; data : CandyShared };
    /// };
    enum NFTUpdateRequest: Codable {
        case update(token_id: String, update: UpdateRequestShared, app_id: String)
        case replace(token_id: String, data: CandyShared)
        
        enum CodingKeys: Int, CodingKey {
            case update = 2265286153
            case replace = 2871543860
        }
    }
    
    /// type NFTUpdateResult = variant { ok : NFTUpdateResponse; err : OrigynError };
    enum NFTUpdateResult: Codable {
        case ok(NFTUpdateResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type NftError = variant {
    ///   UnauthorizedOperator;
    ///   SelfTransfer;
    ///   TokenNotFound;
    ///   UnauthorizedOwner;
    ///   TxNotFound;
    ///   SelfApprove;
    ///   OperatorNotFound;
    ///   ExistedNFT;
    ///   OwnerNotFound;
    ///   Other : text;
    /// };
    enum NftError: Codable {
        case UnauthorizedOperator
        case SelfTransfer
        case TokenNotFound
        case UnauthorizedOwner
        case TxNotFound
        case SelfApprove
        case OperatorNotFound
        case ExistedNFT
        case OwnerNotFound
        case Other(String)
        
        enum CodingKeys: Int, CodingKey {
            case UnauthorizedOperator = 9872920
            case SelfTransfer = 143306487
            case TokenNotFound = 831816744
            case UnauthorizedOwner = 1193721151
            case TxNotFound = 1743789555
            case SelfApprove = 2364232449
            case OperatorNotFound = 2424294419
            case ExistedNFT = 2755912742
            case OwnerNotFound = 2972607330
            case Other = 3382957744
        }
    }
    
    /// type Nft_Canister = service {
    ///   __advance_time : (int) -> (int);
    ///   __set_time_mode : (variant { test; standard }) -> (bool);
    ///   __supports : () -> (vec record { text; text }) query;
    ///   __version : () -> (text) query;
    ///   back_up : (nat) -> (
    ///       variant { eof : NFTBackupChunk; data : NFTBackupChunk },
    ///     ) query;
    ///   balance : (EXTBalanceRequest) -> (EXTBalanceResult) query;
    ///   balanceEXT : (EXTBalanceRequest) -> (EXTBalanceResult) query;
    ///   balance_of_batch_nft_origyn : (vec Account) -> (vec BalanceResult) query;
    ///   balance_of_nft_origyn : (Account) -> (BalanceResult) query;
    ///   balance_of_secure_batch_nft_origyn : (vec Account) -> (vec BalanceResult);
    ///   balance_of_secure_nft_origyn : (Account) -> (BalanceResult);
    ///   bearer : (EXTTokenIdentifier) -> (EXTBearerResult) query;
    ///   bearerEXT : (EXTTokenIdentifier) -> (EXTBearerResult) query;
    ///   bearer_batch_nft_origyn : (vec text) -> (vec BearerResult) query;
    ///   bearer_batch_secure_nft_origyn : (vec text) -> (vec BearerResult);
    ///   bearer_nft_origyn : (text) -> (BearerResult) query;
    ///   bearer_secure_nft_origyn : (text) -> (BearerResult);
    ///   canister_status : (record { canister_id : canister_id }) -> (canister_status);
    ///   chunk_nft_origyn : (ChunkRequest) -> (ChunkResult) query;
    ///   chunk_secure_nft_origyn : (ChunkRequest) -> (ChunkResult);
    ///   collectCanisterMetrics : () -> () query;
    ///   collection_nft_origyn : (opt vec record { text; opt nat; opt nat }) -> (
    ///       CollectionResult,
    ///     ) query;
    ///   collection_secure_nft_origyn : (
    ///       opt vec record { text; opt nat; opt nat },
    ///     ) -> (CollectionResult);
    ///   collection_update_batch_nft_origyn : (vec ManageCollectionCommand) -> (
    ///       vec OrigynBoolResult,
    ///     );
    ///   collection_update_nft_origyn : (ManageCollectionCommand) -> (
    ///       OrigynBoolResult,
    ///     );
    ///   cycles : () -> (nat) query;
    ///   dip721_balance_of : (principal) -> (nat) query;
    ///   dip721_custodians : () -> (vec principal) query;
    ///   dip721_is_approved_for_all : (principal, principal) -> (
    ///       DIP721BoolResult,
    ///     ) query;
    ///   dip721_logo : () -> (opt text) query;
    ///   dip721_metadata : () -> (DIP721Metadata) query;
    ///   dip721_name : () -> (opt text) query;
    ///   dip721_operator_token_identifiers : (principal) -> (
    ///       DIP721TokensListMetadata,
    ///     ) query;
    ///   dip721_operator_token_metadata : (principal) -> (DIP721TokensMetadata) query;
    ///   dip721_owner_of : (nat) -> (OwnerOfResponse) query;
    ///   dip721_owner_token_identifiers : (principal) -> (
    ///       DIP721TokensListMetadata,
    ///     ) query;
    ///   dip721_owner_token_metadata : (principal) -> (DIP721TokensMetadata) query;
    ///   dip721_stats : () -> (DIP721Stats) query;
    ///   dip721_supported_interfaces : () -> (vec DIP721SupportedInterface) query;
    ///   dip721_symbol : () -> (opt text) query;
    ///   dip721_token_metadata : (nat) -> (DIP721TokenMetadata) query;
    ///   dip721_total_supply : () -> (nat) query;
    ///   dip721_total_transactions : () -> (nat) query;
    ///   dip721_transfer : (principal, nat) -> (DIP721NatResult);
    ///   dip721_transfer_from : (principal, principal, nat) -> (DIP721NatResult);
    ///   getCanisterLog : (opt CanisterLogRequest) -> (opt CanisterLogResponse) query;
    ///   getCanisterMetrics : (GetMetricsParameters) -> (opt CanisterMetrics) query;
    ///   getEXTTokenIdentifier : (text) -> (text) query;
    ///   get_access_key : () -> (OrigynTextResult) query;
    ///   get_halt : () -> (bool) query;
    ///   get_nat_as_token_id_origyn : (nat) -> (text) query;
    ///   get_tip : () -> (Tip) query;
    ///   get_token_id_as_nat : (text) -> (nat) query;
    ///   governance_batch_nft_origyn : (vec GovernanceRequest) -> (
    ///       vec GovernanceResult,
    ///     );
    ///   governance_nft_origyn : (GovernanceRequest) -> (GovernanceResult);
    ///   history_batch_nft_origyn : (vec record { text; opt nat; opt nat }) -> (
    ///       vec HistoryResult,
    ///     ) query;
    ///   history_batch_secure_nft_origyn : (vec record { text; opt nat; opt nat }) -> (
    ///       vec HistoryResult,
    ///     );
    ///   history_nft_origyn : (text, opt nat, opt nat) -> (HistoryResult) query;
    ///   history_secure_nft_origyn : (text, opt nat, opt nat) -> (HistoryResult);
    ///   http_access_key : () -> (OrigynTextResult);
    ///   http_request : (HttpRequest) -> (HTTPResponse) query;
    ///   http_request_streaming_callback : (StreamingCallbackToken) -> (
    ///       StreamingCallbackResponse,
    ///     ) query;
    ///   icrc3_get_archives : (GetArchivesArgs) -> (GetArchivesResult) query;
    ///   icrc3_get_blocks : (vec TransactionRange) -> (GetTransactionsResult) query;
    ///   icrc3_get_tip_certificate : () -> (opt DataCertificate) query;
    ///   icrc3_supported_block_types : () -> (vec BlockType) query;
    ///   icrc7_approve : (ApprovalArgs) -> (ApprovalResult);
    ///   icrc7_atomic_batch_transfers : () -> (opt bool) query;
    ///   icrc7_balance_of : (vec Account__3) -> (vec nat) query;
    ///   icrc7_collection_metadata : () -> (CollectionMetadata) query;
    ///   icrc7_default_take_value : () -> (opt nat) query;
    ///   icrc7_description : () -> (opt text) query;
    ///   icrc7_logo : () -> (opt text) query;
    ///   icrc7_max_approvals_per_token_or_collection : () -> (opt nat) query;
    ///   icrc7_max_memo_size : () -> (opt nat) query;
    ///   icrc7_max_query_batch_size : () -> (opt nat) query;
    ///   icrc7_max_revoke_approvals : () -> (opt nat) query;
    ///   icrc7_max_take_value : () -> (opt nat) query;
    ///   icrc7_max_update_batch_size : () -> (opt nat) query;
    ///   icrc7_name : () -> (text) query;
    ///   icrc7_owner_of : (vec nat) -> (vec opt Account__3) query;
    ///   icrc7_permitted_drift : () -> (opt nat) query;
    ///   icrc7_supply_cap : () -> (opt nat) query;
    ///   icrc7_supported_standards : () -> (vec SupportedStandard) query;
    ///   icrc7_symbol : () -> (text) query;
    ///   icrc7_token_metadata : (vec nat) -> (
    ///       vec opt vec record { text; Value },
    ///     ) query;
    ///   icrc7_tokens : (opt nat, opt nat32) -> (vec nat) query;
    ///   icrc7_tokens_of : (Account__3, opt nat, opt nat32) -> (vec nat) query;
    ///   icrc7_total_supply : () -> (nat) query;
    ///   icrc7_transfer : (vec TransferArgs) -> (TransferResult);
    ///   icrc7_transfer_fee : (nat) -> (opt nat) query;
    ///   icrc7_tx_window : () -> (opt nat) query;
    ///   manage_storage_nft_origyn : (ManageStorageRequest) -> (ManageStorageResult);
    ///   market_transfer_batch_nft_origyn : (vec MarketTransferRequest) -> (
    ///       vec MarketTransferResult,
    ///     );
    ///   market_transfer_nft_origyn : (MarketTransferRequest) -> (
    ///       MarketTransferResult,
    ///     );
    ///   metadata : () -> (DIP721Metadata) query;
    ///   metadataExt : (EXTTokenIdentifier) -> (EXTMetadataResult) query;
    ///   mint_batch_nft_origyn : (vec record { text; Account }) -> (
    ///       vec OrigynTextResult,
    ///     );
    ///   mint_nft_origyn : (text, Account) -> (OrigynTextResult);
    ///   nftStreamingCallback : (StreamingCallbackToken) -> (
    ///       StreamingCallbackResponse,
    ///     ) query;
    ///   nft_batch_origyn : (vec text) -> (vec NFTInfoResult) query;
    ///   nft_batch_secure_origyn : (vec text) -> (vec NFTInfoResult);
    ///   nft_origyn : (text) -> (NFTInfoResult) query;
    ///   nft_secure_origyn : (text) -> (NFTInfoResult);
    ///   operaterTokenMetadata : (principal) -> (DIP721TokensMetadata) query;
    ///   ownerOf : (nat) -> (OwnerOfResponse) query;
    ///   ownerTokenMetadata : (principal) -> (DIP721TokensMetadata) query;
    ///   sale_batch_nft_origyn : (vec ManageSaleRequest) -> (vec ManageSaleResult);
    ///   sale_info_batch_nft_origyn : (vec SaleInfoRequest) -> (
    ///       vec SaleInfoResult,
    ///     ) query;
    ///   sale_info_batch_secure_nft_origyn : (vec SaleInfoRequest) -> (
    ///       vec SaleInfoResult,
    ///     );
    ///   sale_info_nft_origyn : (SaleInfoRequest) -> (SaleInfoResult) query;
    ///   sale_info_secure_nft_origyn : (SaleInfoRequest) -> (SaleInfoResult);
    ///   sale_nft_origyn : (ManageSaleRequest) -> (ManageSaleResult);
    ///   set_data_harvester : (nat) -> ();
    ///   set_halt : (bool) -> ();
    ///   share_wallet_nft_origyn : (ShareWalletRequest) -> (OwnerUpdateResult);
    ///   stage_batch_nft_origyn : (vec record { metadata : CandyShared }) -> (
    ///       vec OrigynTextResult,
    ///     );
    ///   stage_library_batch_nft_origyn : (vec StageChunkArg) -> (
    ///       vec StageLibraryResult,
    ///     );
    ///   stage_library_nft_origyn : (StageChunkArg) -> (StageLibraryResult);
    ///   stage_nft_origyn : (record { metadata : CandyShared }) -> (OrigynTextResult);
    ///   state_size : () -> (StateSize) query;
    ///   storage_info_nft_origyn : () -> (StorageMetricsResult) query;
    ///   storage_info_secure_nft_origyn : () -> (StorageMetricsResult);
    ///   tokens_ext : (text) -> (EXTTokensResult) query;
    ///   transfer : (EXTTransferRequest) -> (EXTTransferResponse);
    ///   transferDip721 : (principal, nat) -> (DIP721NatResult);
    ///   transferEXT : (EXTTransferRequest) -> (EXTTransferResponse);
    ///   transferFrom : (principal, principal, nat) -> (DIP721NatResult);
    ///   transferFromDip721 : (principal, principal, nat) -> (DIP721NatResult);
    ///   update_app_nft_origyn : (NFTUpdateRequest) -> (NFTUpdateResult);
    ///   update_icrc3 : (vec UpdateSetting) -> (vec bool);
    ///   wallet_receive : () -> (nat);
    ///   whoami : () -> (principal) query;
    /// };
    class Nft_Canister {
        let canister: ICPPrincipal
        let client: ICPRequestClient
        
        init(canister: ICPPrincipal, client: ICPRequestClient) {
            self.canister = canister
            self.client = client
        }
        
        func __advance_time(_ arg0: BigInt, sender: ICPSigningPrincipal? = nil) async throws -> BigInt {
            let method = ICPMethod(
                canister: canister,
                methodName: "__advance_time",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func __set_time_mode(_ arg0: UnnamedType26, sender: ICPSigningPrincipal? = nil) async throws -> Bool {
            let method = ICPMethod(
                canister: canister,
                methodName: "__set_time_mode",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func __supports(sender: ICPSigningPrincipal? = nil) async throws -> [HeaderField] {
            let method = ICPMethod(canister: canister,  methodName: "__supports")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func __version(sender: ICPSigningPrincipal? = nil) async throws -> String {
            let method = ICPMethod(canister: canister,  methodName: "__version")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func back_up(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> UnnamedType27 {
            let method = ICPMethod(
                canister: canister,
                methodName: "back_up",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func balance(_ arg0: EXTBalanceRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTBalanceResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "balance",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func balanceEXT(_ arg0: EXTBalanceRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTBalanceResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "balanceEXT",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func balance_of_batch_nft_origyn(_ arg0: [Account], sender: ICPSigningPrincipal? = nil) async throws -> [BalanceResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "balance_of_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func balance_of_nft_origyn(_ arg0: Account, sender: ICPSigningPrincipal? = nil) async throws -> BalanceResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "balance_of_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func balance_of_secure_batch_nft_origyn(_ arg0: [Account], sender: ICPSigningPrincipal? = nil) async throws -> [BalanceResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "balance_of_secure_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func balance_of_secure_nft_origyn(_ arg0: Account, sender: ICPSigningPrincipal? = nil) async throws -> BalanceResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "balance_of_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func bearer(_ arg0: EXTTokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> EXTBearerResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "bearer",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func bearerEXT(_ arg0: EXTTokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> EXTBearerResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "bearerEXT",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func bearer_batch_nft_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [BearerResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "bearer_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func bearer_batch_secure_nft_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [BearerResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "bearer_batch_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func bearer_nft_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> BearerResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "bearer_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func bearer_secure_nft_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> BearerResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "bearer_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func canister_status(_ arg0: UnnamedType28, sender: ICPSigningPrincipal? = nil) async throws -> canister_status {
            let method = ICPMethod(
                canister: canister,
                methodName: "canister_status",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func chunk_nft_origyn(_ arg0: ChunkRequest, sender: ICPSigningPrincipal? = nil) async throws -> ChunkResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "chunk_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func chunk_secure_nft_origyn(_ arg0: ChunkRequest, sender: ICPSigningPrincipal? = nil) async throws -> ChunkResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "chunk_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func collectCanisterMetrics(sender: ICPSigningPrincipal? = nil) async throws {
            let method = ICPMethod(canister: canister,  methodName: "collectCanisterMetrics")
            _ = try await client.query(method, effectiveCanister: canister, sender: sender)
        }
        
        func collection_nft_origyn(_ arg0: [UnnamedType11]?, sender: ICPSigningPrincipal? = nil) async throws -> CollectionResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "collection_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func collection_secure_nft_origyn(_ arg0: [UnnamedType11]?, sender: ICPSigningPrincipal? = nil) async throws -> CollectionResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "collection_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func collection_update_batch_nft_origyn(_ arg0: [ManageCollectionCommand], sender: ICPSigningPrincipal? = nil) async throws -> [OrigynBoolResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "collection_update_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func collection_update_nft_origyn(_ arg0: ManageCollectionCommand, sender: ICPSigningPrincipal? = nil) async throws -> OrigynBoolResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "collection_update_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func cycles(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let method = ICPMethod(canister: canister,  methodName: "cycles")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_balance_of(_ arg0: CandidPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_balance_of",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_custodians(sender: ICPSigningPrincipal? = nil) async throws -> [CandidPrincipal] {
            let method = ICPMethod(canister: canister,  methodName: "dip721_custodians")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_is_approved_for_all(_ arg0: UnnamedType29, sender: ICPSigningPrincipal? = nil) async throws -> DIP721BoolResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_is_approved_for_all",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_logo(sender: ICPSigningPrincipal? = nil) async throws -> String? {
            let method = ICPMethod(canister: canister,  methodName: "dip721_logo")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_metadata(sender: ICPSigningPrincipal? = nil) async throws -> DIP721Metadata {
            let method = ICPMethod(canister: canister,  methodName: "dip721_metadata")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_name(sender: ICPSigningPrincipal? = nil) async throws -> String? {
            let method = ICPMethod(canister: canister,  methodName: "dip721_name")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_operator_token_identifiers(_ arg0: CandidPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensListMetadata {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_operator_token_identifiers",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_operator_token_metadata(_ arg0: CandidPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_operator_token_metadata",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_owner_of(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> OwnerOfResponse {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_owner_of",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_owner_token_identifiers(_ arg0: CandidPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensListMetadata {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_owner_token_identifiers",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_owner_token_metadata(_ arg0: CandidPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_owner_token_metadata",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_stats(sender: ICPSigningPrincipal? = nil) async throws -> DIP721Stats {
            let method = ICPMethod(canister: canister,  methodName: "dip721_stats")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_supported_interfaces(sender: ICPSigningPrincipal? = nil) async throws -> [DIP721SupportedInterface] {
            let method = ICPMethod(canister: canister,  methodName: "dip721_supported_interfaces")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String? {
            let method = ICPMethod(canister: canister,  methodName: "dip721_symbol")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_token_metadata(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokenMetadata {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_token_metadata",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_total_supply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let method = ICPMethod(canister: canister,  methodName: "dip721_total_supply")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_total_transactions(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let method = ICPMethod(canister: canister,  methodName: "dip721_total_transactions")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_transfer(_ arg0: UnnamedType2, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_transfer",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func dip721_transfer_from(_ arg0: UnnamedType30, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "dip721_transfer_from",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func getCanisterLog(_ arg0: CanisterLogRequest?, sender: ICPSigningPrincipal? = nil) async throws -> CanisterLogResponse? {
            let method = ICPMethod(
                canister: canister,
                methodName: "getCanisterLog",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func getCanisterMetrics(_ arg0: GetMetricsParameters, sender: ICPSigningPrincipal? = nil) async throws -> CanisterMetrics? {
            let method = ICPMethod(
                canister: canister,
                methodName: "getCanisterMetrics",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func getEXTTokenIdentifier(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> String {
            let method = ICPMethod(
                canister: canister,
                methodName: "getEXTTokenIdentifier",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func get_access_key(sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
            let method = ICPMethod(canister: canister,  methodName: "get_access_key")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func get_halt(sender: ICPSigningPrincipal? = nil) async throws -> Bool {
            let method = ICPMethod(canister: canister,  methodName: "get_halt")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func get_nat_as_token_id_origyn(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> String {
            let method = ICPMethod(
                canister: canister,
                methodName: "get_nat_as_token_id_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func get_tip(sender: ICPSigningPrincipal? = nil) async throws -> Tip {
            let method = ICPMethod(canister: canister,  methodName: "get_tip")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func get_token_id_as_nat(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let method = ICPMethod(
                canister: canister,
                methodName: "get_token_id_as_nat",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func governance_batch_nft_origyn(_ arg0: [GovernanceRequest], sender: ICPSigningPrincipal? = nil) async throws -> [GovernanceResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "governance_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func governance_nft_origyn(_ arg0: GovernanceRequest, sender: ICPSigningPrincipal? = nil) async throws -> GovernanceResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "governance_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func history_batch_nft_origyn(_ arg0: [UnnamedType11], sender: ICPSigningPrincipal? = nil) async throws -> [HistoryResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "history_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func history_batch_secure_nft_origyn(_ arg0: [UnnamedType11], sender: ICPSigningPrincipal? = nil) async throws -> [HistoryResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "history_batch_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func history_nft_origyn(_ arg0: UnnamedType11, sender: ICPSigningPrincipal? = nil) async throws -> HistoryResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "history_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func history_secure_nft_origyn(_ arg0: UnnamedType11, sender: ICPSigningPrincipal? = nil) async throws -> HistoryResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "history_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func http_access_key(sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
            let method = ICPMethod(canister: canister,  methodName: "http_access_key")
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func http_request(_ arg0: HttpRequest, sender: ICPSigningPrincipal? = nil) async throws -> HTTPResponse {
            let method = ICPMethod(
                canister: canister,
                methodName: "http_request",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func http_request_streaming_callback(_ arg0: StreamingCallbackToken, sender: ICPSigningPrincipal? = nil) async throws -> StreamingCallbackResponse {
            let method = ICPMethod(
                canister: canister,
                methodName: "http_request_streaming_callback",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc3_get_archives(_ arg0: GetArchivesArgs, sender: ICPSigningPrincipal? = nil) async throws -> GetArchivesResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc3_get_archives",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc3_get_blocks(_ arg0: [TransactionRange], sender: ICPSigningPrincipal? = nil) async throws -> GetTransactionsResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc3_get_blocks",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc3_get_tip_certificate(sender: ICPSigningPrincipal? = nil) async throws -> DataCertificate? {
            let method = ICPMethod(canister: canister,  methodName: "icrc3_get_tip_certificate")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc3_supported_block_types(sender: ICPSigningPrincipal? = nil) async throws -> [BlockType] {
            let method = ICPMethod(canister: canister,  methodName: "icrc3_supported_block_types")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_approve(_ arg0: ApprovalArgs, sender: ICPSigningPrincipal? = nil) async throws -> ApprovalResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_approve",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_atomic_batch_transfers(sender: ICPSigningPrincipal? = nil) async throws -> Bool? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_atomic_batch_transfers")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_balance_of(_ arg0: [Account__3], sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_balance_of",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_collection_metadata(sender: ICPSigningPrincipal? = nil) async throws -> CollectionMetadata {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_collection_metadata")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_default_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_default_take_value")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_description(sender: ICPSigningPrincipal? = nil) async throws -> String? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_description")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_logo(sender: ICPSigningPrincipal? = nil) async throws -> String? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_logo")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_max_approvals_per_token_or_collection(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_max_approvals_per_token_or_collection")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_max_memo_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_max_memo_size")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_max_query_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_max_query_batch_size")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_max_revoke_approvals(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_max_revoke_approvals")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_max_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_max_take_value")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_max_update_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_max_update_batch_size")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_name(sender: ICPSigningPrincipal? = nil) async throws -> String {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_name")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_owner_of(_ arg0: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [Account__3?] {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_owner_of",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_permitted_drift(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_permitted_drift")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_supply_cap(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_supply_cap")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_supported_standards(sender: ICPSigningPrincipal? = nil) async throws -> [SupportedStandard] {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_supported_standards")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_symbol")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_token_metadata(_ arg0: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [[UnnamedType12]?] {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_token_metadata",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_tokens(_ arg0: UnnamedType31, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_tokens",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_tokens_of(_ arg0: UnnamedType32, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_tokens_of",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_total_supply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_total_supply")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_transfer(_ arg0: [TransferArgs], sender: ICPSigningPrincipal? = nil) async throws -> TransferResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_transfer",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_transfer_fee(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(
                canister: canister,
                methodName: "icrc7_transfer_fee",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func icrc7_tx_window(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
            let method = ICPMethod(canister: canister,  methodName: "icrc7_tx_window")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func manage_storage_nft_origyn(_ arg0: ManageStorageRequest, sender: ICPSigningPrincipal? = nil) async throws -> ManageStorageResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "manage_storage_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func market_transfer_batch_nft_origyn(_ arg0: [MarketTransferRequest], sender: ICPSigningPrincipal? = nil) async throws -> [MarketTransferResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "market_transfer_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func market_transfer_nft_origyn(_ arg0: MarketTransferRequest, sender: ICPSigningPrincipal? = nil) async throws -> MarketTransferResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "market_transfer_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func metadata(sender: ICPSigningPrincipal? = nil) async throws -> DIP721Metadata {
            let method = ICPMethod(canister: canister,  methodName: "metadata")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func metadataExt(_ arg0: EXTTokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> EXTMetadataResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "metadataExt",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func mint_batch_nft_origyn(_ arg0: [UnnamedType33], sender: ICPSigningPrincipal? = nil) async throws -> [OrigynTextResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "mint_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func mint_nft_origyn(_ arg0: UnnamedType33, sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "mint_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func nftStreamingCallback(_ arg0: StreamingCallbackToken, sender: ICPSigningPrincipal? = nil) async throws -> StreamingCallbackResponse {
            let method = ICPMethod(
                canister: canister,
                methodName: "nftStreamingCallback",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func nft_batch_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [NFTInfoResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "nft_batch_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func nft_batch_secure_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [NFTInfoResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "nft_batch_secure_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func nft_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> NFTInfoResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func nft_secure_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> NFTInfoResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "nft_secure_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func operaterTokenMetadata(_ arg0: CandidPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
            let method = ICPMethod(
                canister: canister,
                methodName: "operaterTokenMetadata",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func ownerOf(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> OwnerOfResponse {
            let method = ICPMethod(
                canister: canister,
                methodName: "ownerOf",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func ownerTokenMetadata(_ arg0: CandidPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
            let method = ICPMethod(
                canister: canister,
                methodName: "ownerTokenMetadata",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func sale_batch_nft_origyn(_ arg0: [ManageSaleRequest], sender: ICPSigningPrincipal? = nil) async throws -> [ManageSaleResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "sale_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func sale_info_batch_nft_origyn(_ arg0: [SaleInfoRequest], sender: ICPSigningPrincipal? = nil) async throws -> [SaleInfoResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "sale_info_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func sale_info_batch_secure_nft_origyn(_ arg0: [SaleInfoRequest], sender: ICPSigningPrincipal? = nil) async throws -> [SaleInfoResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "sale_info_batch_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func sale_info_nft_origyn(_ arg0: SaleInfoRequest, sender: ICPSigningPrincipal? = nil) async throws -> SaleInfoResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "sale_info_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func sale_info_secure_nft_origyn(_ arg0: SaleInfoRequest, sender: ICPSigningPrincipal? = nil) async throws -> SaleInfoResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "sale_info_secure_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func sale_nft_origyn(_ arg0: ManageSaleRequest, sender: ICPSigningPrincipal? = nil) async throws -> ManageSaleResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "sale_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func set_data_harvester(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws {
            let method = ICPMethod(
                canister: canister,
                methodName: "set_data_harvester",
                args: try CandidEncoder().encode(arg0)
            )
            _ = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
        }
        
        func set_halt(_ arg0: Bool, sender: ICPSigningPrincipal? = nil) async throws {
            let method = ICPMethod(
                canister: canister,
                methodName: "set_halt",
                args: try CandidEncoder().encode(arg0)
            )
            _ = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
        }
        
        func share_wallet_nft_origyn(_ arg0: ShareWalletRequest, sender: ICPSigningPrincipal? = nil) async throws -> OwnerUpdateResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "share_wallet_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func stage_batch_nft_origyn(_ arg0: [UnnamedType34], sender: ICPSigningPrincipal? = nil) async throws -> [OrigynTextResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "stage_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func stage_library_batch_nft_origyn(_ arg0: [StageChunkArg], sender: ICPSigningPrincipal? = nil) async throws -> [StageLibraryResult] {
            let method = ICPMethod(
                canister: canister,
                methodName: "stage_library_batch_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func stage_library_nft_origyn(_ arg0: StageChunkArg, sender: ICPSigningPrincipal? = nil) async throws -> StageLibraryResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "stage_library_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func stage_nft_origyn(_ arg0: UnnamedType34, sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "stage_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func state_size(sender: ICPSigningPrincipal? = nil) async throws -> StateSize {
            let method = ICPMethod(canister: canister,  methodName: "state_size")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func storage_info_nft_origyn(sender: ICPSigningPrincipal? = nil) async throws -> StorageMetricsResult {
            let method = ICPMethod(canister: canister,  methodName: "storage_info_nft_origyn")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func storage_info_secure_nft_origyn(sender: ICPSigningPrincipal? = nil) async throws -> StorageMetricsResult {
            let method = ICPMethod(canister: canister,  methodName: "storage_info_secure_nft_origyn")
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func tokens_ext(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> EXTTokensResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "tokens_ext",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func transfer(_ arg0: EXTTransferRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTTransferResponse {
            let method = ICPMethod(
                canister: canister,
                methodName: "transfer",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func transferDip721(_ arg0: UnnamedType2, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "transferDip721",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func transferEXT(_ arg0: EXTTransferRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTTransferResponse {
            let method = ICPMethod(
                canister: canister,
                methodName: "transferEXT",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func transferFrom(_ arg0: UnnamedType30, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "transferFrom",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func transferFromDip721(_ arg0: UnnamedType30, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "transferFromDip721",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func update_app_nft_origyn(_ arg0: NFTUpdateRequest, sender: ICPSigningPrincipal? = nil) async throws -> NFTUpdateResult {
            let method = ICPMethod(
                canister: canister,
                methodName: "update_app_nft_origyn",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func update_icrc3(_ arg0: [UpdateSetting], sender: ICPSigningPrincipal? = nil) async throws -> [Bool] {
            let method = ICPMethod(
                canister: canister,
                methodName: "update_icrc3",
                args: try CandidEncoder().encode(arg0)
            )
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func wallet_receive(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
            let method = ICPMethod(canister: canister,  methodName: "wallet_receive")
            let response = try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
        func whoami(sender: ICPSigningPrincipal? = nil) async throws -> CandidPrincipal {
            let method = ICPMethod(canister: canister,  methodName: "whoami")
            let response = try await client.query(method, effectiveCanister: canister, sender: sender)
            return try CandidDecoder().decode(response)
        }
        
    }
    
    /// type NiftySettlementType = record {
    ///   fixed : bool;
    ///   interestRatePerSecond : float64;
    ///   duration : opt int;
    ///   expiration : opt int;
    ///   lenderOffer : bool;
    /// };
    struct NiftySettlementType: Codable {
        let fixed: Bool
        let interestRatePerSecond: Double
        let duration: BigInt?
        let expiration: BigInt?
        let lenderOffer: Bool
    }
    
    /// type NumericEntity = record {
    ///   avg : nat64;
    ///   max : nat64;
    ///   min : nat64;
    ///   first : nat64;
    ///   last : nat64;
    /// };
    struct NumericEntity: Codable {
        let avg: UInt64
        let max: UInt64
        let min: UInt64
        let first: UInt64
        let last: UInt64
    }
    
    /// type OrigynBoolResult = variant { ok : bool; err : OrigynError };
    enum OrigynBoolResult: Codable {
        case ok(Bool)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type OrigynError = record {
    ///   "text" : text;
    ///   error : Errors;
    ///   number : nat32;
    ///   flag_point : text;
    /// };
    struct OrigynError: Codable {
        let text: String
        let error: Errors
        let number: UInt32
        let flag_point: String
    }
    
    /// type OrigynTextResult = variant { ok : text; err : OrigynError };
    enum OrigynTextResult: Codable {
        case ok(String)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type OwnerOfResponse = variant { Ok : opt principal; Err : NftError };
    enum OwnerOfResponse: Codable {
        case Ok(CandidPrincipal?)
        case Err(NftError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    /// type OwnerTransferResponse = record {
    ///   transaction : TransactionRecord;
    ///   assets : vec CandyShared;
    /// };
    struct OwnerTransferResponse: Codable {
        let transaction: TransactionRecord
        let assets: [CandyShared]
    }
    
    /// type OwnerUpdateResult = variant {
    ///   ok : OwnerTransferResponse;
    ///   err : OrigynError;
    /// };
    enum OwnerUpdateResult: Codable {
        case ok(OwnerTransferResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type PricingConfigShared = variant {
    ///   ask : AskConfigShared;
    ///   extensible : CandyShared;
    ///   instant : InstantConfigShared;
    ///   auction : AuctionConfig;
    /// };
    enum PricingConfigShared: Codable {
        case ask(AskConfigShared)
        case extensible(CandyShared)
        case instant(InstantConfigShared)
        case auction(AuctionConfig)
        
        enum CodingKeys: Int, CodingKey {
            case ask = 4849465
            case extensible = 2305203451
            case instant = 2375735009
            case auction = 3607851587
        }
    }
    
    /// type PropertyShared = record {
    ///   value : CandyShared;
    ///   name : text;
    ///   immutable : bool;
    /// };
    struct PropertyShared: Codable {
        let value: CandyShared
        let name: String
        let immutable: Bool
    }
    
    /// type RecognizeEscrowResponse = record {
    ///   balance : nat;
    ///   receipt : EscrowReceipt;
    ///   transaction : opt TransactionRecord;
    /// };
    struct RecognizeEscrowResponse: Codable {
        let balance: BigUInt
        let receipt: EscrowReceipt
        let transaction: TransactionRecord?
    }
    
    /// type RejectDescription = record {
    ///   token : TokenSpec__1;
    ///   token_id : text;
    ///   seller : Account;
    ///   buyer : Account;
    /// };
    struct RejectDescription: Codable {
        let token: TokenSpec__1
        let token_id: String
        let seller: Account
        let buyer: Account
    }
    
    /// type SaleInfoRequest = variant {
    ///   status : text;
    ///   fee_deposit_info : opt Account;
    ///   active : opt record { nat; nat };
    ///   deposit_info : opt Account;
    ///   history : opt record { nat; nat };
    ///   escrow_info : EscrowReceipt;
    /// };
    enum SaleInfoRequest: Codable {
        case status(String)
        case fee_deposit_info(Account?)
        case active(UnnamedType35?)
        case deposit_info(Account?)
        case history(UnnamedType35?)
        case escrow_info(EscrowReceipt)
        
        enum CodingKeys: Int, CodingKey {
            case status = 100394802
            case fee_deposit_info = 221783304
            case active = 373703110
            case deposit_info = 938558511
            case history = 1682388308
            case escrow_info = 3659094312
        }
    }
    
    /// type SaleInfoResponse = variant {
    ///   status : opt SaleStatusShared;
    ///   fee_deposit_info : SubAccountInfo;
    ///   active : record {
    ///     eof : bool;
    ///     records : vec record { text; opt SaleStatusShared };
    ///     count : nat;
    ///   };
    ///   deposit_info : SubAccountInfo;
    ///   history : record {
    ///     eof : bool;
    ///     records : vec opt SaleStatusShared;
    ///     count : nat;
    ///   };
    ///   escrow_info : SubAccountInfo;
    /// };
    enum SaleInfoResponse: Codable {
        case status(SaleStatusShared?)
        case fee_deposit_info(SubAccountInfo)
        case active(eof: Bool, records: [UnnamedType36], count: BigUInt)
        case deposit_info(SubAccountInfo)
        case history(eof: Bool, records: [SaleStatusShared?], count: BigUInt)
        case escrow_info(SubAccountInfo)
        
        enum CodingKeys: Int, CodingKey {
            case status = 100394802
            case fee_deposit_info = 221783304
            case active = 373703110
            case deposit_info = 938558511
            case history = 1682388308
            case escrow_info = 3659094312
        }
    }
    
    /// type SaleInfoResult = variant { ok : SaleInfoResponse; err : OrigynError };
    enum SaleInfoResult: Codable {
        case ok(SaleInfoResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type SaleStatusShared = record {
    ///   token_id : text;
    ///   sale_type : variant { auction : AuctionStateShared };
    ///   broker_id : opt principal;
    ///   original_broker_id : opt principal;
    ///   sale_id : text;
    /// };
    struct SaleStatusShared: Codable {
        let token_id: String
        let sale_type: UnnamedType37
        let broker_id: CandidPrincipal?
        let original_broker_id: CandidPrincipal?
        let sale_id: String
    }
    
    /// type SalesConfig = record {
    ///   broker_id : opt Account__1;
    ///   pricing : PricingConfigShared;
    ///   escrow_receipt : opt EscrowReceipt__1;
    /// };
    struct SalesConfig: Codable {
        let broker_id: Account__1?
        let pricing: PricingConfigShared
        let escrow_receipt: EscrowReceipt__1?
    }
    
    /// type ShareWalletRequest = record {
    ///   to : Account;
    ///   token_id : text;
    ///   from : Account;
    /// };
    struct ShareWalletRequest: Codable {
        let to: Account
        let token_id: String
        let from: Account
    }
    
    /// type StableBucketData = record {
    ///   "principal" : principal;
    ///   allocated_space : nat;
    ///   date_added : int;
    ///   version : record { nat; nat; nat };
    ///   b_gateway : bool;
    ///   available_space : nat;
    ///   allocations : vec record { record { text; text }; int };
    /// };
    struct StableBucketData: Codable {
        let principal: CandidPrincipal
        let allocated_space: BigUInt
        let date_added: BigInt
        let version: UnnamedType20
        let b_gateway: Bool
        let available_space: BigUInt
        let allocations: [UnnamedType38]
    }
    
    /// type StableCollectionData = record {
    ///   active_bucket : opt principal;
    ///   managers : vec principal;
    ///   owner : principal;
    ///   metadata : opt CandyShared;
    ///   logo : opt text;
    ///   name : opt text;
    ///   network : opt principal;
    ///   available_space : nat;
    ///   symbol : opt text;
    ///   allocated_storage : nat;
    /// };
    struct StableCollectionData: Codable {
        let active_bucket: CandidPrincipal?
        let managers: [CandidPrincipal]
        let owner: CandidPrincipal
        let metadata: CandyShared?
        let logo: String?
        let name: String?
        let network: CandidPrincipal?
        let available_space: BigUInt
        let symbol: String?
        let allocated_storage: BigUInt
    }
    
    /// type StageChunkArg = record {
    ///   content : vec nat8;
    ///   token_id : text;
    ///   chunk : nat;
    ///   filedata : CandyShared;
    ///   library_id : text;
    /// };
    struct StageChunkArg: Codable {
        let content: Data
        let token_id: String
        let chunk: BigUInt
        let filedata: CandyShared
        let library_id: String
    }
    
    /// type StageLibraryResponse = record { canister : principal };
    struct StageLibraryResponse: Codable {
        let canister: CandidPrincipal
    }
    
    /// type StageLibraryResult = variant {
    ///   ok : StageLibraryResponse;
    ///   err : OrigynError;
    /// };
    enum StageLibraryResult: Codable {
        case ok(StageLibraryResponse)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type StakeRecord = record { staker : Account; token_id : text; amount : nat };
    struct StakeRecord: Codable {
        let staker: Account
        let token_id: String
        let amount: BigUInt
    }
    
    /// type StateSize = record {
    ///   sales_balances : nat;
    ///   offers : nat;
    ///   nft_ledgers : nat;
    ///   allocations : nat;
    ///   nft_sales : nat;
    ///   buckets : nat;
    ///   escrow_balances : nat;
    /// };
    struct StateSize: Codable {
        let sales_balances: BigUInt
        let offers: BigUInt
        let nft_ledgers: BigUInt
        let allocations: BigUInt
        let nft_sales: BigUInt
        let buckets: BigUInt
        let escrow_balances: BigUInt
    }
    
    /// type StorageMetrics = record {
    ///   gateway : principal;
    ///   available_space : nat;
    ///   allocations : vec AllocationRecordStable;
    ///   allocated_storage : nat;
    /// };
    struct StorageMetrics: Codable {
        let gateway: CandidPrincipal
        let available_space: BigUInt
        let allocations: [AllocationRecordStable]
        let allocated_storage: BigUInt
    }
    
    /// type StorageMetricsResult = variant { ok : StorageMetrics; err : OrigynError };
    enum StorageMetricsResult: Codable {
        case ok(StorageMetrics)
        case err(OrigynError)
        
        enum CodingKeys: Int, CodingKey {
            case ok = 24860
            case err = 5048165
        }
    }
    
    /// type StreamingCallbackResponse = record {
    ///   token : opt StreamingCallbackToken;
    ///   body : vec nat8;
    /// };
    struct StreamingCallbackResponse: Codable {
        let token: StreamingCallbackToken?
        let body: Data
    }
    
    /// type StreamingCallbackToken = record {
    ///   key : text;
    ///   index : nat;
    ///   content_encoding : text;
    /// };
    struct StreamingCallbackToken: Codable {
        let key: String
        let index: BigUInt
        let content_encoding: String
    }
    
    /// type StreamingStrategy = variant {
    ///   Callback : record {
    ///     token : StreamingCallbackToken;
    ///     callback : func () -> ();
    ///   };
    /// };
    enum StreamingStrategy: Codable {
        case Callback(token: StreamingCallbackToken, callback: ICPFunctionNoArgsNoResult)
        
        enum CodingKeys: Int, CodingKey {
            case Callback = 1488475621
        }
    }
    
    /// type SubAccountInfo = record {
    ///   account_id : vec nat8;
    ///   "principal" : principal;
    ///   account_id_text : text;
    ///   account : record { "principal" : principal; sub_account : vec nat8 };
    /// };
    struct SubAccountInfo: Codable {
        let account_id: Data
        let principal: CandidPrincipal
        let account_id_text: String
        let account: UnnamedType42
    }
    
    /// type SupportedStandard = record { url : text; name : text };
    struct SupportedStandard: Codable {
        let url: String
        let name: String
    }
    
    /// type Tip = record {
    ///   last_block_index : vec nat8;
    ///   hash_tree : vec nat8;
    ///   last_block_hash : vec nat8;
    /// };
    struct Tip: Codable {
        let last_block_index: Data
        let hash_tree: Data
        let last_block_hash: Data
    }
    
    /// type TokenIDFilter = record {
    ///   filter_type : variant { allow; block };
    ///   token_id : text;
    ///   tokens : vec record {
    ///     token : TokenSpec__1;
    ///     min_amount : opt nat;
    ///     max_amount : opt nat;
    ///   };
    /// };
    struct TokenIDFilter: Codable {
        let filter_type: UnnamedType43
        let token_id: String
        let tokens: [UnnamedType44]
    }
    
    /// type TokenMetadata = record {
    ///   transferred_at : opt nat64;
    ///   transferred_by : opt principal;
    ///   owner : opt principal;
    ///   operator : opt principal;
    ///   approved_at : opt nat64;
    ///   approved_by : opt principal;
    ///   properties : vec record { text; GenericValue };
    ///   is_burned : bool;
    ///   token_identifier : nat;
    ///   burned_at : opt nat64;
    ///   burned_by : opt principal;
    ///   minted_at : nat64;
    ///   minted_by : principal;
    /// };
    struct TokenMetadata: Codable {
        let transferred_at: UInt64?
        let transferred_by: CandidPrincipal?
        let owner: CandidPrincipal?
        let `operator`: CandidPrincipal?
        let approved_at: UInt64?
        let approved_by: CandidPrincipal?
        let properties: [UnnamedType45]
        let is_burned: Bool
        let token_identifier: BigUInt
        let burned_at: UInt64?
        let burned_by: CandidPrincipal?
        let minted_at: UInt64
        let minted_by: CandidPrincipal
    }
    
    /// type TokenSpec = variant { ic : ICTokenSpec; extensible : CandyShared };
    enum TokenSpec: Codable {
        case ic(ICTokenSpec)
        case extensible(CandyShared)
        
        enum CodingKeys: Int, CodingKey {
            case ic = 23514
            case extensible = 2305203451
        }
    }
    
    /// type TokenSpecFilter = record {
    ///   token : TokenSpec__1;
    ///   filter_type : variant { allow; block };
    /// };
    struct TokenSpecFilter: Codable {
        let token: TokenSpec__1
        let filter_type: UnnamedType43
    }
    
    /// type TokenSpec__1 = variant { ic : ICTokenSpec__1; extensible : CandyShared };
    enum TokenSpec__1: Codable {
        case ic(ICTokenSpec__1)
        case extensible(CandyShared)
        
        enum CodingKeys: Int, CodingKey {
            case ic = 23514
            case extensible = 2305203451
        }
    }
    
    /// type TransactionID = variant {
    ///   "nat" : nat;
    ///   "text" : text;
    ///   extensible : CandyShared;
    /// };
    enum TransactionID: Codable {
        case nat(BigUInt)
        case text(String)
        case extensible(CandyShared)
        
        enum CodingKeys: Int, CodingKey {
            case nat = 5491937
            case text = 1291439277
            case extensible = 2305203451
        }
    }
    
    /// type TransactionRange = record { start : nat; length : nat };
    struct TransactionRange: Codable {
        let start: BigUInt
        let length: BigUInt
    }
    
    /// type TransferArgs = record {
    ///   to : Account__3;
    ///   token_id : nat;
    ///   memo : opt vec nat8;
    ///   from_subaccount : opt vec nat8;
    ///   created_at_time : opt nat64;
    /// };
    struct TransferArgs: Codable {
        let to: Account__3
        let token_id: BigUInt
        let memo: Data?
        let from_subaccount: Data?
        let created_at_time: UInt64?
    }
    
    /// type TransferError = variant {
    ///   GenericError : record { message : text; error_code : nat };
    ///   Duplicate : record { duplicate_of : nat };
    ///   NonExistingTokenId;
    ///   Unauthorized;
    ///   CreatedInFuture : record { ledger_time : nat64 };
    ///   TooOld;
    /// };
    enum TransferError: Codable {
        case GenericError(message: String, error_code: BigUInt)
        case Duplicate(duplicate_of: BigUInt)
        case NonExistingTokenId
        case Unauthorized
        case CreatedInFuture(ledger_time: UInt64)
        case TooOld
        
        enum CodingKeys: Int, CodingKey {
            case GenericError = 260448849
            case Duplicate = 1122632043
            case NonExistingTokenId = 1457030524
            case Unauthorized = 2471582292
            case CreatedInFuture = 2608432112
            case TooOld = 3373249171
        }
    }
    
    /// type TransferResultItem = record {
    ///   token_id : nat;
    ///   transfer_result : variant { Ok : nat; Err : TransferError };
    /// };
    struct TransferResultItem: Codable {
        let token_id: BigUInt
        let transfer_result: UnnamedType46
    }
    
    enum UnnamedType0: Codable {
        case Ok(BigUInt)
        case Err(ApprovalError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    struct UnnamedType1: Codable {
        let token_id: BigUInt
        let approval_result: UnnamedType0
    }
    
    struct UnnamedType10: Codable {
        let _0: CandyShared
        let _1: CandyShared
        
        init(_ _0: CandyShared, _ _1: CandyShared) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType11: Codable {
        let _0: String
        let _1: BigUInt?
        let _2: BigUInt?
        
        init(_ _0: String, _ _1: BigUInt?, _ _2: BigUInt?) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
        }
    }
    
    struct UnnamedType12: Codable {
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
    
    enum UnnamedType13: Codable {
        case day(BigUInt)
        case hour(BigUInt)
        case minute(BigUInt)
        
        enum CodingKeys: Int, CodingKey {
            case day = 4994652
            case hour = 1158861092
            case minute = 1393025748
        }
    }
    
    enum UnnamedType14: Codable {
        case flat(BigUInt)
        case percent(Double)
        
        enum CodingKeys: Int, CodingKey {
            case flat = 1136528313
            case percent = 2027596485
        }
    }
    
    struct UnnamedType15: Codable {
        let locked: BigInt?
        let seller: CandidPrincipal
        let price: UInt64
    }
    
    enum UnnamedType16: Codable {
        case CannotNotify(EXTAccountIdentifier)
        case InsufficientBalance
        case InvalidToken(EXTTokenIdentifier)
        case Rejected
        case Unauthorized(EXTAccountIdentifier)
        case Other(String)
        
        enum CodingKeys: Int, CodingKey {
            case CannotNotify = 1476496972
            case InsufficientBalance = 1653746489
            case InvalidToken = 2173912226
            case Rejected = 2234891166
            case Unauthorized = 2471582292
            case Other = 3382957744
        }
    }
    
    enum UnnamedType17: Codable {
        case locked(sale_id: String)
        case unlocked
        
        enum CodingKeys: Int, CodingKey {
            case locked = 1506215178
            case unlocked = 1544434723
        }
    }
    
    struct UnnamedType18: Codable {
        let id: BigUInt
        let block: Value__1
    }
    
    enum UnnamedType19: Codable {
        case ICRC1
        case EXTFungible
        case DIP20
        case Other(CandyShared)
        case Ledger
        
        enum CodingKeys: Int, CodingKey {
            case ICRC1 = 885528518
            case EXTFungible = 1092001659
            case DIP20 = 1471997353
            case Other = 3382957744
            case Ledger = 3439319497
        }
    }
    
    struct UnnamedType2: Codable {
        let _0: CandidPrincipal
        let _1: BigUInt
        
        init(_ _0: CandidPrincipal, _ _1: BigUInt) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType20: Codable {
        let _0: BigUInt
        let _1: BigUInt
        let _2: BigUInt
        
        init(_ _0: BigUInt, _ _1: BigUInt, _ _2: BigUInt) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
        }
    }
    
    struct UnnamedType21: Codable {
        let _0: CandidPrincipal
        let _1: BigUInt
        let _2: UnnamedType20
        
        init(_ _0: CandidPrincipal, _ _1: BigUInt, _ _2: UnnamedType20) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
        }
    }
    
    enum UnnamedType22: Codable {
        case stableBtree(BigUInt?)
        case heap(BigUInt?)
        
        enum CodingKeys: Int, CodingKey {
            case stableBtree = 318793221
            case heap = 1158359340
        }
    }
    
    struct UnnamedType23: Codable {
        let _0: HeaderField
        let _1: AllocationRecordStable
        
        init(_ _0: HeaderField, _ _1: AllocationRecordStable) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType24: Codable {
        let _0: String
        let _1: SaleStatusShared
        
        init(_ _0: String, _ _1: SaleStatusShared) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType25: Codable {
        let _0: CandidPrincipal
        let _1: StableBucketData
        
        init(_ _0: CandidPrincipal, _ _1: StableBucketData) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    enum UnnamedType26: Codable {
        case test
        case standard
        
        enum CodingKeys: Int, CodingKey {
            case test = 1291438162
            case standard = 3933747005
        }
    }
    
    enum UnnamedType27: Codable {
        case eof(NFTBackupChunk)
        case data(NFTBackupChunk)
        
        enum CodingKeys: Int, CodingKey {
            case eof = 5047484
            case data = 1113806378
        }
    }
    
    struct UnnamedType28: Codable {
        let canister_id: canister_id
    }
    
    struct UnnamedType29: Codable {
        let _0: CandidPrincipal
        let _1: CandidPrincipal
        
        init(_ _0: CandidPrincipal, _ _1: CandidPrincipal) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType3: Codable {
        let tokens: [TokenSpecFilter]?
        let token_ids: [TokenIDFilter]?
    }
    
    struct UnnamedType30: Codable {
        let _0: CandidPrincipal
        let _1: CandidPrincipal
        let _2: BigUInt
        
        init(_ _0: CandidPrincipal, _ _1: CandidPrincipal, _ _2: BigUInt) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
        }
    }
    
    struct UnnamedType31: Codable {
        let _0: BigUInt?
        let _1: UInt32?
        
        init(_ _0: BigUInt?, _ _1: UInt32?) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType32: Codable {
        let _0: Account__3
        let _1: BigUInt?
        let _2: UInt32?
        
        init(_ _0: Account__3, _ _1: BigUInt?, _ _2: UInt32?) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
        }
    }
    
    struct UnnamedType33: Codable {
        let _0: String
        let _1: Account
        
        init(_ _0: String, _ _1: Account) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType34: Codable {
        let metadata: CandyShared
    }
    
    struct UnnamedType35: Codable {
        let _0: BigUInt
        let _1: BigUInt
        
        init(_ _0: BigUInt, _ _1: BigUInt) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType36: Codable {
        let _0: String
        let _1: SaleStatusShared?
        
        init(_ _0: String, _ _1: SaleStatusShared?) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    enum UnnamedType37: Codable {
        case auction(AuctionStateShared)
        
        enum CodingKeys: Int, CodingKey {
            case auction = 3607851587
        }
    }
    
    struct UnnamedType38: Codable {
        let _0: HeaderField
        let _1: BigInt
        
        init(_ _0: HeaderField, _ _1: BigInt) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType39: Codable {
        let _0: Account
        let _1: Account
        let _2: String
        let _3: EscrowRecord__1
        
        init(_ _0: Account, _ _1: Account, _ _2: String, _ _3: EscrowRecord__1) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
            self._3 = _3
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
            case _3 = 3
        }
    }
    
    enum UnnamedType4: Codable {
        case date(BigInt)
        case wait_for_quiet(max: BigUInt, date: BigInt, fade: Double, extension: UInt64)
        
        enum CodingKeys: Int, CodingKey {
            case date = 1113806382
            case wait_for_quiet = 1541627444
        }
    }
    
    struct UnnamedType40: Codable {
        let _0: String
        let _1: TransactionRecord
        
        init(_ _0: String, _ _1: TransactionRecord) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType41: Codable {
        let _0: Account
        let _1: Account
        let _2: BigInt
        
        init(_ _0: Account, _ _1: Account, _ _2: BigInt) {
            self._0 = _0
            self._1 = _1
            self._2 = _2
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
            case _2 = 2
        }
    }
    
    struct UnnamedType42: Codable {
        let principal: CandidPrincipal
        let sub_account: Data
    }
    
    enum UnnamedType43: Codable {
        case allow
        case block
        
        enum CodingKeys: Int, CodingKey {
            case allow = 563324041
            case block = 3036443981
        }
    }
    
    struct UnnamedType44: Codable {
        let token: TokenSpec__1
        let min_amount: BigUInt?
        let max_amount: BigUInt?
    }
    
    struct UnnamedType45: Codable {
        let _0: String
        let _1: GenericValue
        
        init(_ _0: String, _ _1: GenericValue) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    enum UnnamedType46: Codable {
        case Ok(BigUInt)
        case Err(TransferError)
        
        enum CodingKeys: Int, CodingKey {
            case Ok = 17724
            case Err = 3456837
        }
    }
    
    struct UnnamedType47: Codable {
        let _0: String
        let _1: Value__1
        
        init(_ _0: String, _ _1: Value__1) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    enum UnnamedType48: Codable {
        case stopped
        case stopping
        case running
        
        enum CodingKeys: Int, CodingKey {
            case stopped = 1130484237
            case stopping = 2990082932
            case running = 3949555199
        }
    }
    
    enum UnnamedType5: Codable {
        case closed
        case open
        case not_started
        
        enum CodingKeys: Int, CodingKey {
            case closed = 240232876
            case open = 1236534218
            case not_started = 3289589461
        }
    }
    
    struct UnnamedType6: Codable {
        let _0: CandidPrincipal
        let _1: BigInt
        
        init(_ _0: CandidPrincipal, _ _1: BigInt) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType7: Codable {
        let _0: CandidPrincipal
        let _1: Bool
        
        init(_ _0: CandidPrincipal, _ _1: Bool) {
            self._0 = _0
            self._1 = _1
        }
        
        enum CodingKeys: Int, CodingKey {
            case _0 = 0
            case _1 = 1
        }
    }
    
    struct UnnamedType8: Codable {
        let token: TokenSpec
        let amount: BigUInt
    }
    
    enum UnnamedType9: Codable {
        case escrow_deposit(token: TokenSpec, token_id: String, trx_id: TransactionID, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
        case fee_deposit(token: TokenSpec, extensible: CandyShared, account: Account__1, amount: BigUInt)
        case canister_network_updated(network: CandidPrincipal, extensible: CandyShared)
        case escrow_withdraw(fee: BigUInt, token: TokenSpec, token_id: String, trx_id: TransactionID, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
        case canister_managers_updated(managers: [CandidPrincipal], extensible: CandyShared)
        case auction_bid(token: TokenSpec, extensible: CandyShared, buyer: Account__1, amount: BigUInt, sale_id: String)
        case burn(from: Account__1?, extensible: CandyShared)
        case data(hash: Data?, extensible: CandyShared, data_dapp: String?, data_path: String?)
        case sale_ended(token: TokenSpec, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt, sale_id: String?)
        case mint(to: Account__1, from: Account__1, sale: UnnamedType8?, extensible: CandyShared)
        case royalty_paid(tag: String, token: TokenSpec, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt, receiver: Account__1, sale_id: String?)
        case extensible(CandyShared)
        case fee_deposit_withdraw(fee: BigUInt, token: TokenSpec, trx_id: TransactionID, extensible: CandyShared, account: Account__1, amount: BigUInt)
        case owner_transfer(to: Account__1, from: Account__1, extensible: CandyShared)
        case sale_opened(pricing: PricingConfigShared, extensible: CandyShared, sale_id: String)
        case canister_owner_updated(owner: CandidPrincipal, extensible: CandyShared)
        case sale_withdraw(fee: BigUInt, token: TokenSpec, token_id: String, trx_id: TransactionID, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
        case deposit_withdraw(fee: BigUInt, token: TokenSpec, trx_id: TransactionID, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
        
        enum CodingKeys: Int, CodingKey {
            case escrow_deposit = 53258980
            case fee_deposit = 268167461
            case canister_network_updated = 796598546
            case escrow_withdraw = 817439428
            case canister_managers_updated = 901050234
            case auction_bid = 966479233
            case burn = 1092621391
            case data = 1113806378
            case sale_ended = 1150169602
            case mint = 1214008994
            case royalty_paid = 1341020447
            case extensible = 2305203451
            case fee_deposit_withdraw = 2623233700
            case owner_transfer = 2966417399
            case sale_opened = 3740033185
            case canister_owner_updated = 3858892695
            case sale_withdraw = 3960506626
            case deposit_withdraw = 4163935563
        }
    }
    
    /// type UpdateModeShared = variant {
    ///   Set : CandyShared;
    ///   Lock : CandyShared;
    ///   Next : vec UpdateShared;
    /// };
    enum UpdateModeShared: Codable {
        case Set(CandyShared)
        case Lock(CandyShared)
        case Next([UpdateShared])
        
        enum CodingKeys: Int, CodingKey {
            case Set = 4150146
            case Lock = 848349195
            case Next = 870035731
        }
    }
    
    /// type UpdateRequestShared = record { id : text; update : vec UpdateShared };
    struct UpdateRequestShared: Codable {
        let id: String
        let update: [UpdateShared]
    }
    
    /// type UpdateSetting = variant {
    ///   maxRecordsToArchive : nat;
    ///   archiveIndexType : IndexType;
    ///   maxArchivePages : nat;
    ///   settleToRecords : nat;
    ///   archiveCycles : nat;
    ///   maxActiveRecords : nat;
    ///   maxRecordsInArchiveInstance : nat;
    ///   archiveControllers : opt opt vec principal;
    /// };
    enum UpdateSetting: Codable {
        case maxRecordsToArchive(BigUInt)
        case archiveIndexType(IndexType)
        case maxArchivePages(BigUInt)
        case settleToRecords(BigUInt)
        case archiveCycles(BigUInt)
        case maxActiveRecords(BigUInt)
        case maxRecordsInArchiveInstance(BigUInt)
        case archiveControllers([CandidPrincipal]??)
        
        enum CodingKeys: Int, CodingKey {
            case maxRecordsToArchive = 166783273
            case archiveIndexType = 1457204938
            case maxArchivePages = 1537975526
            case settleToRecords = 1593449852
            case archiveCycles = 2866207343
            case maxActiveRecords = 3033334360
            case maxRecordsInArchiveInstance = 3340002996
            case archiveControllers = 3436881845
        }
    }
    
    /// type UpdateShared = record { mode : UpdateModeShared; name : text };
    struct UpdateShared: Codable {
        let mode: UpdateModeShared
        let name: String
    }
    
    /// type Value = variant {
    ///   Int : int;
    ///   Map : vec record { text; Value };
    ///   Nat : nat;
    ///   Blob : vec nat8;
    ///   Text : text;
    ///   Array : vec Value;
    /// };
    enum Value: Codable {
        case Int(BigInt)
        case Map([UnnamedType12])
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
    
    /// type Value__1 = variant {
    ///   Int : int;
    ///   Map : vec record { text; Value__1 };
    ///   Nat : nat;
    ///   Blob : vec nat8;
    ///   Text : text;
    ///   Array : vec Value__1;
    /// };
    enum Value__1: Codable {
        case Int(BigInt)
        case Map([UnnamedType47])
        case Nat(BigUInt)
        case Blob(Data)
        case Text(String)
        case Array([Value__1])
        
        enum CodingKeys: Int, CodingKey {
            case Int = 3654863
            case Map = 3850876
            case Nat = 3900609
            case Blob = 737307005
            case Text = 936573133
            case Array = 3099385209
        }
    }
    
    /// type WaitForQuietType = record { max : nat; fade : float64; extension : nat64 };
    struct WaitForQuietType: Codable {
        let max: BigUInt
        let fade: Double
        let `extension`: UInt64
    }
    
    /// type WithdrawDescription = record {
    ///   token : TokenSpec__1;
    ///   token_id : text;
    ///   seller : Account;
    ///   withdraw_to : Account;
    ///   buyer : Account;
    ///   amount : nat;
    /// };
    struct WithdrawDescription: Codable {
        let token: TokenSpec__1
        let token_id: String
        let seller: Account
        let withdraw_to: Account
        let buyer: Account
        let amount: BigUInt
    }
    
    /// type WithdrawRequest = variant {
    ///   reject : RejectDescription;
    ///   fee_deposit : FeeDepositWithdrawDescription;
    ///   sale : WithdrawDescription;
    ///   deposit : DepositWithdrawDescription;
    ///   escrow : WithdrawDescription;
    /// };
    enum WithdrawRequest: Codable {
        case reject(RejectDescription)
        case fee_deposit(FeeDepositWithdrawDescription)
        case sale(WithdrawDescription)
        case deposit(DepositWithdrawDescription)
        case escrow(WithdrawDescription)
        
        enum CodingKeys: Int, CodingKey {
            case reject = 42291551
            case fee_deposit = 268167461
            case sale = 1280148103
            case deposit = 1728387934
            case escrow = 3672582405
        }
    }
    
    /// type canister_status = record {
    ///   status : variant { stopped; stopping; running };
    ///   memory_size : nat;
    ///   cycles : nat;
    ///   settings : definite_canister_settings;
    ///   module_hash : opt vec nat8;
    /// };
    struct canister_status: Codable {
        let status: UnnamedType48
        let memory_size: BigUInt
        let cycles: BigUInt
        let settings: definite_canister_settings
        let module_hash: Data?
    }
    
    /// type definite_canister_settings = record {
    ///   freezing_threshold : nat;
    ///   controllers : opt vec principal;
    ///   memory_allocation : nat;
    ///   compute_allocation : nat;
    /// };
    struct definite_canister_settings: Codable {
        let freezing_threshold: BigUInt
        let controllers: [CandidPrincipal]?
        let memory_allocation: BigUInt
        let compute_allocation: BigUInt
    }
    
    
    typealias Service = Nft_Canister
    
}

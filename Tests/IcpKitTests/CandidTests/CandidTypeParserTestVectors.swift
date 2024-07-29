//
//  CandidTypeParserTestVectors.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation
@testable import IcpKit

enum CandidTypeParserTestVectors {
    static let passingSingleTypes: [(String, CandidType)] = [
        ("null", .null),
        ("bool", .bool),
        ("nat", .natural),
        ("int", .integer),
        ("nat8", .natural8),
        ("nat16", .natural16),
        ("nat32", .natural32),
        ("nat64", .natural64),
        ("int8", .integer8),
        ("int16", .integer16),
        ("int32", .integer32),
        ("int64", .integer64),
        ("float32", .float32),
        ("float64", .float64),
        ("text", .text),
        ("reserved", .reserved),
        ("empty", .empty),
        ("blob", .blob),
        ("principal", .principal),
        ("null ignored", .null),
        ("  null ignored", .null),
        ("\n\tnull", .null),
        
        ("opt null", .option(.null)),
        ("opt nat8", .option(.natural8)),
        ("opt text", .option(.text)),
        
        ("vec int", .vector(.integer)),
        ("vec opt nat8", .vector(.option(.natural8))),
        ("vec vec text", .vector(.vector(.text))),
        ("  vec\tint  ", .vector(.integer)),
        ("\n\tvec\tint  ", .vector(.integer)),
        
        ("variant {}", .variant([])),
        ("variant { ok : nat; error : text }", .variant(["ok": .natural, "error": .text])),
        ("variant { ok : nat; error : text; }", .variant(["ok": .natural, "error": .text])),
        ("variant { ok : vec nat8 }", .variant(["ok": .vector(.natural8)])),
        (#"variant { "name with spaces" : nat; "unicode, too: ☃" : bool }"#, .variant(["name with spaces": .natural, "unicode, too: ☃": .bool])),
        ("variant { spring; summer; fall; winter }", .variant(["spring": .null, "summer": .null, "fall": .null, "winter": .null])),
        (#"variant { "vec nat 8" : variant {} }"#, .variant(["vec nat 8": .variant()])),
        ("variant{v:variant{}}", .variant(["v": .variant()])),
        
        ("record {}", .record()),
        ("record { first_name : text; text : text }", .record(["first_name": .text, "text": .text])),
        (#"record { "name with spaces" : nat; "unicode, too: ☃" : bool }"#, .record(["name with spaces": .natural, "unicode, too: ☃": .bool])),
        ("record { text; text; opt bool }", .record([CandidKeyedItemType(hashedKey: 0, type: .text),CandidKeyedItemType(hashedKey: 1, type: .text),CandidKeyedItemType(hashedKey: 2, type: .option(.bool))])),
        (#"record{record{opt bool};"key":text}"#, .record([CandidKeyedItemType(hashedKey: 0, type:  .record([CandidKeyedItemType(hashedKey: 0, type: .option(.bool))])), CandidKeyedItemType("key", .text)])),
        
        ("func () -> ()", .function()),
        ("func () -> () oneway", .function(oneWay: true)),
        ("func (text, opt bool) -> (text)", .function([.text, .option(.bool)], [.text])),
        ("func () -> (int) query", .function([], [.integer], query: true)),
        ("func (func (int) -> ()) -> ()", .function([.function([.integer], [])], [])),
        
        ("service {}", .service()),
        ("service { search : (query : text, callback : func (vec nat) -> ()) -> (); }",
            .service([
                .init("search", [("query", .text), ("callback", .function([.vector(.natural)], []))],[])
            ])),
        ("service { set_address: (name : text, addr : nat) -> (); get_address: (name : text) -> (opt nat) query; }",
            .service([
                .init("set_address", [("name", .text), ("addr", .natural)], []),
                .init("get_address", [("name", .text)], [(nil, .option(.natural))], query: true),
            ])),
    ]
    
    static let comments: [(String)] = [
        ("no comment"),
        ("type A = bool // a bool"),
        ("""
        type A = bool // a bool
        type B = bool // another bool
        """),
        ("""
        type A = bool // a bool
        /* multiline comment */
        /* another
        one*/
        type B = bool // another bool
        /* a last one */
        """),
    ]
    
    static let functionArgumentNames: [(String, CandidType, [String], [String])] = [
        ("func (dividend : nat, divisor : nat) -> (div : nat, mod : nat);", .function([.natural, .natural], [.natural, .natural]), ["dividend", "divisor"], ["div", "mod"]),
        (#"func ("dividend with space" : nat, "divisor" : nat) -> ("🐂" : nat, mod : nat);"#, .function([.natural, .natural], [.natural, .natural]), ["dividend with space", "divisor"], ["🐂", "mod"]),
    ]
    
    static let failingSingleTypes: [String] = [
        "",
        "\t",
        " ",
        "opt",
        "opt vec",
        "opt 0",
    ]
    
    static let didFiles: [(String, [String: CandidType], CandidInterfaceDefinition.ServiceDefinition?)] = [
        ("", [:], nil),
        ("type A = nat;", ["A": .natural], nil),
        ("type _ = nat;", ["_": .natural], nil),
        ("type _0 = nat;", ["_0": .natural], nil),
        ("type A = nat;type B = vec A;", ["A": .natural, "B": .vector(.named("A"))], nil),
        ("type stream = opt record {head : nat; next : func () -> (stream)};", ["stream": .option(.record([
            .init("head", .natural), .init("next", .function([], [.named("stream")]))
        ]))], nil),
        ("type node = record {head : nat; tail : list};type list = opt node;", [
            "node": .record([.init("head", .natural), .init("tail", .named("list"))]),
            "list": .option(.named("node")),
        ], nil),
        (#"type A = nat;type B = vec A;type C = service { "foo": (A) -> (B); };"#, [
            "A": .natural,
            "B": .vector(.named("A")),
            "C": .service([.init("foo", [.named("A")], [.named("B")])])
        ], nil),
//        "street": .text,
//        "city": .text,
//        "zip_code": .natural,
//        "country": .text
        ("type A = record { 288167939 : text; 1103114667 : text; 220614283 : nat; 492419670 : text;};", ["A": .record([
                .init(hashedKey: 288167939, type: .text),
                .init(hashedKey: 1103114667, type: .text),
                .init(hashedKey: 220614283, type: .natural),
                .init(hashedKey: 492419670, type: .text),
        ])], nil),
        ("service: {};", [:], .init(name: nil, initialisationArguments: nil, signature: .init([]))),
        ("service: {}", [:], .init(name: nil, initialisationArguments: nil, signature: .init([]))),
        ("service:(nat)-> {};", [:], .init(name: nil, initialisationArguments: [.init(index: 0, name: nil, type: .natural)], signature: .init([]))),
        ("service:()-> {};", [:], .init(name: nil, initialisationArguments: [], signature: .init([]))),
        ("service:(nat:nat)-> {};", [:], .init(name: nil, initialisationArguments: [.init(index: 0, name: "nat", type: .natural)], signature: .init([]))),
        ("service add:(nat)-> {foo: ()->()query;};", [:], .init(name: "add", initialisationArguments: [.init(index: 0, name: nil, type: .natural)], signature: .init([.init("foo", query: true)]))),
        ("type s = service{};service: s;", ["s":.service()], .init(name: nil, initialisationArguments: nil, signatureReference: "s")),
        ("type s = service{};service foo: (nat)-> s;", ["s":.service()], .init(name: "foo", initialisationArguments: [.init(index: 0, name: nil, type: .natural)], signatureReference: "s")),
        ("type f=func ()->();type s=service{foo:f;};", ["f":.function(), "s":.service([.init(name: "foo", signatureReference: "f")])], nil)
    ]
    
    static let originalStringDid: [(String, [String: String])] = [
        ("type A = vec nat;", ["A":"type A = vec nat;"]),
        ("type A = vec nat;type B = A;", ["A":"type A = vec nat;", "B": "type B = A;"]),
    ]
    
    static let unresolvedDidFiles: [String] = [
        "type B = vec A;",
        "type B = A;",
        "type B = record { a: A };",
        "type B = func (A) -> ();",
        "type B = func () -> (A);",
        "type B = service { foo: (A) -> (); };",
        "service: B;",
        "type A = nat; service: A;",
        "service: (B) -> {};",
        "service: { foo: (B) -> (); };",
        "service: { foo: () -> (A); };",
    ]
    
    static let failingDidFiles: [String] = [
        "type B = nat; type B = opt nat;",  // redeclaration of B
        "type A = nat", // no ending semi-colon
        "type 0abc = nat", // invalid id
        "type -abc = nat", // invalid id
        "type abc#v = nat", // invalid id
        "type 🐂 = nat", // invalid id
        "type ☃ = nat", // invalid id
    ]
    
    static let importedFiles: [(mainDid: String, files: [String: String], types: [String: CandidType], CandidInterfaceDefinition.ServiceDefinition?)] = [
        ("import file1.did;", ["file1.did": "type A=nat;"], ["A":.natural], nil),
        ("import file1.did;type B = opt A;", ["file1.did": "type A=nat;"], ["A":.natural, "B": .option(.named("A"))], nil),
        ("type B = opt A;import file1.did;", ["file1.did": "type A=nat;"], ["A":.natural, "B": .option(.named("A"))], nil),
        ("import file1.did;", ["file1.did": "type A=nat;service: {};"], ["A":.natural], nil),
        ("import file1.did;", ["file1.did": "type A=nat;service add: {};"], ["A":.natural], nil),
        ("import service file1.did;", ["file1.did": "type A=nat;service: {};"], ["A":.natural], .init(name: nil, initialisationArguments: nil, signature: .init([]))),
        ("import service file1.did;", ["file1.did": "type A=nat;service add: {};"], ["A":.natural], .init(name: "add", initialisationArguments: nil, signature: .init([]))),
        ("import file1.did;service sub: S;", ["file1.did": "type A=nat;type S=service{};service add: {};"], ["A":.natural, "S":.service()], .init(name: "sub", initialisationArguments: nil, signatureReference: "S")),
        ("import service file1.did;type B=nat;", ["file1.did": "type A=nat;service add: {};"], ["A":.natural, "B":.natural], .init(name: "add", initialisationArguments: nil, signature: .init([]))),
    ]
    
    static let failingImportedFiles: [(mainDid: String, files: [String:String])] = [
        ("import file1", [:]),  // file not found
        ("import service file1;service: {}", ["file1":"service: {}"]) // 2 services
    ]
    
    static let realWorldExamples: [(source: String, typeCount: Int, methodCount: Int)] = [
        (evmDidFile, 46, 23),
        (icrc7DidFile, 6, 21),
    ]
    
    /// https://github.com/internet-computer-protocol/evm-rpc-canister/blob/main/candid/evm_rpc.did#L253
    static let evmDidFile = """
type Auth = variant { FreeRpc; PriorityRpc; RegisterProvider; Manage };
type Block = record {
  miner : text;
  totalDifficulty : opt nat;
  receiptsRoot : text;
  stateRoot : text;
  hash : text;
  difficulty : opt nat;
  size : nat;
  uncles : vec text;
  baseFeePerGas : opt nat;
  extraData : text;
  transactionsRoot : opt text;
  sha3Uncles : text;
  nonce : nat;
  number : nat;
  timestamp : nat;
  transactions : vec text;
  gasLimit : nat;
  logsBloom : text;
  parentHash : text;
  gasUsed : nat;
  mixHash : text;
};
type BlockTag = variant {
  Earliest;
  Safe;
  Finalized;
  Latest;
  Number : nat;
  Pending;
};
type EthMainnetService = variant {
  Alchemy;
  Ankr;
  BlockPi;
  Cloudflare;
  PublicNode;
  Llama;
};
type EthSepoliaService = variant {
  Alchemy;
  Ankr;
  BlockPi;
  PublicNode;
};
type L2MainnetService = variant {
  Alchemy;
  Ankr;
  BlockPi;
  PublicNode;
  Llama;
};
type FeeHistory = record {
  reward : vec vec nat;
  gasUsedRatio : vec float64;
  oldestBlock : nat;
  baseFeePerGas : vec nat;
};
type FeeHistoryArgs = record {
  blockCount : nat;
  newestBlock : BlockTag;
  rewardPercentiles : opt vec nat8;
};
type GetLogsArgs = record {
  fromBlock : opt BlockTag;
  toBlock : opt BlockTag;
  addresses : vec text;
  topics : opt vec Topic;
};
type GetTransactionCountArgs = record { address : text; block : BlockTag };
type HttpHeader = record { value : text; name : text };
type HttpOutcallError = variant {
  IcError : record { code : RejectionCode; message : text };
  InvalidHttpJsonRpcResponse : record {
    status : nat16;
    body : text;
    parsingError : opt text;
  };
};
type InitArgs = record {
  nodesInSubnet : nat32;
};
type JsonRpcError = record { code : int64; message : text };
type LogEntry = record {
  transactionHash : opt text;
  blockNumber : opt nat;
  data : text;
  blockHash : opt text;
  transactionIndex : opt nat;
  topics : vec text;
  address : text;
  logIndex : opt nat;
  removed : bool;
};
type ManageProviderArgs = record {
  providerId : nat64;
  chainId: opt nat64;
  "service" : opt RpcService;
  primary : opt bool;
};
type Metrics = record {
  requests : vec record { record { text; text }; nat64 };
  responses : vec record { record { text; text; text }; nat64 };
  inconsistentResponses : vec record { record { text; text }; nat64 };
  cyclesCharged : vec record { record { text; text }; nat };
  cyclesWithdrawn : nat;
  errNoPermission : nat64;
  errHttpOutcall : vec record { record { text; text }; nat64 };
  errHostNotAllowed : vec record { text; nat64 };
};
type MultiFeeHistoryResult = variant {
  Consistent : FeeHistoryResult;
  Inconsistent : vec record { RpcService; FeeHistoryResult };
};
type MultiGetBlockByNumberResult = variant {
  Consistent : GetBlockByNumberResult;
  Inconsistent : vec record { RpcService; GetBlockByNumberResult };
};
type MultiGetLogsResult = variant {
  Consistent : GetLogsResult;
  Inconsistent : vec record { RpcService; GetLogsResult };
};
type MultiGetTransactionCountResult = variant {
  Consistent : GetTransactionCountResult;
  Inconsistent : vec record { RpcService; GetTransactionCountResult };
};
type MultiGetTransactionReceiptResult = variant {
  Consistent : GetTransactionReceiptResult;
  Inconsistent : vec record { RpcService; GetTransactionReceiptResult };
};
type MultiSendRawTransactionResult = variant {
  Consistent : SendRawTransactionResult;
  Inconsistent : vec record { RpcService; SendRawTransactionResult };
};
type ProviderError = variant {
  TooFewCycles : record { expected : nat; received : nat };
  MissingRequiredProvider;
  ProviderNotFound;
  NoPermission;
};
type ProviderId = nat64;
type ProviderView = record {
  cyclesPerCall : nat64;
  owner : principal;
  hostname : text;
  primary : bool;
  chainId : nat64;
  cyclesPerMessageByte : nat64;
  providerId : nat64;
};
type RegisterProviderArgs = record {
  cyclesPerCall : nat64;
  credentialPath : text;
  hostname : text;
  credentialHeaders : opt vec HttpHeader;
  chainId : nat64;
  cyclesPerMessageByte : nat64;
};
type RejectionCode = variant {
  NoError;
  CanisterError;
  SysTransient;
  DestinationInvalid;
  Unknown;
  SysFatal;
  CanisterReject;
};
type FeeHistoryResult = variant { Ok : opt FeeHistory; Err : RpcError };
type GetBlockByNumberResult = variant { Ok : Block; Err : RpcError };
type GetLogsResult = variant { Ok : vec LogEntry; Err : RpcError };
type GetTransactionCountResult = variant { Ok : nat; Err : RpcError };
type GetTransactionReceiptResult = variant {
  Ok : opt TransactionReceipt;
  Err : RpcError;
};
type SendRawTransactionResult = variant {
  Ok : SendRawTransactionStatus;
  Err : RpcError;
};
type RequestResult = variant { Ok : text; Err : RpcError };
type RequestCostResult = variant { Ok : nat; Err : RpcError };
type RpcConfig = record { responseSizeEstimate : opt nat64 };
type RpcError = variant {
  JsonRpcError : JsonRpcError;
  ProviderError : ProviderError;
  ValidationError : ValidationError;
  HttpOutcallError : HttpOutcallError;
};
type RpcApi = record { url : text; headers : opt vec HttpHeader };
type RpcService = variant {
  Chain : nat64;
  Provider : nat64;
  Custom : RpcApi;
  EthSepolia : EthSepoliaService;
  EthMainnet : EthMainnetService;
  ArbitrumOne : L2MainnetService;
  BaseMainnet : L2MainnetService;
  OptimismMainnet : L2MainnetService;
};
type RpcServices = variant {
  Custom : record {
    chainId : nat64;
    services : vec RpcApi;
  };
  EthSepolia : opt vec EthSepoliaService;
  EthMainnet : opt vec EthMainnetService;
  ArbitrumOne : opt vec L2MainnetService;
  BaseMainnet : opt vec L2MainnetService;
  OptimismMainnet : opt vec L2MainnetService;
};
type SendRawTransactionStatus = variant {
  Ok : opt text;
  NonceTooLow;
  NonceTooHigh;
  InsufficientFunds;
};
type Topic = vec text;
type TransactionReceipt = record {
  to : text;
  status : nat;
  transactionHash : text;
  blockNumber : nat;
  from : text;
  logs : vec LogEntry;
  blockHash : text;
  "type" : text;
  transactionIndex : nat;
  effectiveGasPrice : nat;
  logsBloom : text;
  contractAddress : opt text;
  gasUsed : nat;
};
type UpdateProviderArgs = record {
  providerId : nat64;
  cyclesPerCall : opt nat64;
  credentialPath : opt text;
  credentialHeaders : opt vec HttpHeader;
  cyclesPerMessageByte : opt nat64;
};
type ValidationError = variant {
  Custom : text;
  HostNotAllowed : text;
  UrlParseError : text;
  InvalidHex : text;
  CredentialPathNotAllowed;
  CredentialHeaderNotAllowed;
};
service : (InitArgs) -> {
  authorize : (principal, Auth) -> (success : bool);
  deauthorize : (principal, Auth) -> (success : bool);
  eth_feeHistory : (RpcServices, opt RpcConfig, FeeHistoryArgs) -> (MultiFeeHistoryResult);
  eth_getBlockByNumber : (RpcServices, opt RpcConfig, BlockTag) -> (MultiGetBlockByNumberResult);
  eth_getLogs : (RpcServices, opt RpcConfig, GetLogsArgs) -> (MultiGetLogsResult);
  eth_getTransactionCount : (RpcServices, opt RpcConfig, GetTransactionCountArgs) -> (
    MultiGetTransactionCountResult
  );
  eth_getTransactionReceipt : (RpcServices, opt RpcConfig, hash : text) -> (MultiGetTransactionReceiptResult);
  eth_sendRawTransaction : (RpcServices, opt RpcConfig, rawSignedTransactionHex : text) -> (MultiSendRawTransactionResult);
  getAccumulatedCycleCount : (ProviderId) -> (cycles : nat) query;
  getAuthorized : (Auth) -> (vec principal) query;
  getMetrics : () -> (Metrics) query;
  getNodesInSubnet : () -> (numberOfNodes : nat32) query;
  getOpenRpcAccess : () -> (active : bool) query;
  getProviders : () -> (vec ProviderView) query;
  getServiceProviderMap : () -> (vec record { RpcService; nat64 }) query;
  manageProvider : (ManageProviderArgs) -> ();
  registerProvider : (RegisterProviderArgs) -> (nat64);
  request : (RpcService, json : text, maxResponseBytes : nat64) -> (RequestResult);
  requestCost : (RpcService, json : text, maxResponseBytes : nat64) -> (RequestCostResult) query;
  setOpenRpcAccess : (active : bool) -> ();
  unregisterProvider : (ProviderId) -> (bool);
  updateProvider : (UpdateProviderArgs) -> ();
  withdrawAccumulatedCycles : (ProviderId, recipient : principal) -> ();
};
"""
    
    /// https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.did
    static let icrc7DidFile = """
type Subaccount = blob;

type Account = record { owner : principal; subaccount : opt Subaccount };

type Value = variant {
    Blob : blob;
    Text : text;
    Nat : nat;
    Int : int;
    Array : vec Value;
    Map : vec record { text; Value };
};

type TransferArg = record {
    from_subaccount: opt blob;
    to : Account;
    token_id : nat;
    memo : opt blob;
    created_at_time : opt nat64;
};

type TransferResult = variant {
    Ok : nat; 
    Err : TransferError;
};

type TransferError = variant {
    NonExistingTokenId;
    InvalidRecipient;
    Unauthorized;
    TooOld;
    CreatedInFuture : record { ledger_time: nat64 };
    Duplicate : record { duplicate_of : nat };
    GenericError : record { error_code : nat; message : text };
    GenericBatchError : record { error_code : nat; message : text };
};

service : {
  icrc7_collection_metadata : () -> (vec record { text; Value } ) query;
  icrc7_symbol : () -> (text) query;
  icrc7_name : () -> (text) query;
  icrc7_description : () -> (opt text) query;
  icrc7_logo : () -> (opt text) query;
  icrc7_total_supply : () -> (nat) query;
  icrc7_supply_cap : () -> (opt nat) query;
  icrc7_max_query_batch_size : () -> (opt nat) query;
  icrc7_max_update_batch_size : () -> (opt nat) query;
  icrc7_default_take_value : () -> (opt nat) query;
  icrc7_max_take_value : () -> (opt nat) query;
  icrc7_max_memo_size : () -> (opt nat) query;
  icrc7_atomic_batch_transfers : () -> (opt bool) query;
  icrc7_tx_window : () -> (opt nat) query;
  icrc7_permitted_drift : () -> (opt nat) query;
  icrc7_token_metadata : (token_ids : vec nat)
      -> (vec opt vec record { text; Value }) query;
  icrc7_owner_of : (token_ids : vec nat)
      -> (vec opt Account) query;
  icrc7_balance_of : (vec Account) -> (vec nat) query;
  icrc7_tokens : (prev : opt nat, take : opt nat)
      -> (vec nat) query;
  icrc7_tokens_of : (account : Account, prev : opt nat, take : opt nat)
      -> (vec nat) query;
  icrc7_transfer : (vec TransferArg) -> (vec opt TransferResult);
}
"""
}

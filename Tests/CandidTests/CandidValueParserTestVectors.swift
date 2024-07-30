//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 12.07.24.
//

import Foundation
import Candid

enum CandidValueParserTestVectors {
    static let singleValueTests: [(String, CandidValue)] = [
        ("true", .bool(true)),
        ("false", .bool(false)),
        ("false : bool", .bool(false)),
        ("null", .null),
        ("null : null", .null),
        ("(true)", .bool(true)),
        ("((true : bool))", .bool(true)),
        
        // MARK: Text
        (#""""#, .text("")),
        (#""Escaped characters: \n \r \t \\ \" \'""#, .text(#"Escaped characters: \n \r \t \\ \" \'"#)),
        (#""Raw bytes (must be utf8): \E2\98\83 is also ☃""#, .text(#"Raw bytes (must be utf8): \E2\98\83 is also ☃"#)),
        (#""Unicode escapes: \u{2603} is ☃ and \u{221E} is ∞""#, .text(#"Unicode escapes: \u{2603} is ☃ and \u{221E} is ∞"#)),
        (#""some quoted text""#, .text("some quoted text")),
        (#""some quoted text" : text"#, .text("some quoted text")),
        
        // MARK: Integers
        ("123", .natural(123)),
        ("123_12", .natural(12312)),
        ("123_1_2", .natural(12312)),
        ("123_1_2:nat", .natural(12312)),
        ("+123", .integer(123)),
        ("-123", .integer(-123)),
        ("0xF", .natural(15)),
        ("0xf_F", .natural(255)),
        ("0xDEAD_BEEF", .natural(3735928559)),
        ("+0xDEAD_BEEF", .integer(3735928559)),
        ("-0xDEAD_BEEF", .integer(-3735928559)),
        ("8:nat8", .natural8(8)),
        ("8:int8", .integer8(8)),
        ("-8:int8", .integer8(-8)),
        ("1000:nat16", .natural16(1000)),
        ("1000:nat32", .natural32(1000)),
        ("1000:nat64", .natural64(1000)),
        ("1000:int16", .integer16(1000)),
        ("1000:int32", .integer32(1000)),
        ("1000:int64", .integer64(1000)),
        ("-1000:int16", .integer16(-1000)),
        ("-1000:int32", .integer32(-1000)),
        ("-1000:int64", .integer64(-1000)),
        
        // MARK: Floats
        ("1.", .float64(1)),
        ("-1.", .float64(-1)),
        ("1.5", .float64(1.5)),
        ("1.5e2", .float64(150)),
        ("1.5e-2", .float64(0.015)),
        ("1.5E2", .float64(150)),
        ("1.5E+2", .float64(150)),
        ("1.5E-2", .float64(0.015)),
        ("1E2", .float64(100)),
        ("1e-2", .float64(0.01)),
        ("1e-2:float32", .float32(0.01)),
        ("0xDEAD.", .float64(57005)),
        ("-0xDEAD_BEEF.", .float64(-3735928559)),
        ("0xDEAD.BEEF", .float64(57005.488789999996)),
        ("+0xDEAD.BEEFp-1", .float64(5700.5488789999996)),
        ("-0xDEAD.BEEFp+1", .float64(-570054.88789999996)),
        ("-0xDEAD.BEEFp+1:float64", .float64(-570054.88789999996)),
        ("-0xDEAD.BEEFp+1:float32", .float32(-570054.88789999996)),
        
        // MARK: Optionals
        ("opt false", .option(.bool(false))),
        ("opt 8:nat8", .option(.natural8(8))),
        ("opt null", .option(.some(.null))),
        (#"opt opt "text""#, .option(.option(.text("text")))),
        
        // MARK: Vectors
        ("vec {}", .vector(.null)),
        (#"vec { "john@doe.com"; "john.doe@example.com" }"#, try! .vector([.text("john@doe.com"), .text("john.doe@example.com")])),
        ("vec {8;3}", try! .vector([.natural(8), .natural(3)])),
        ("vec {8:nat8;3:nat8}", try! .vector([.natural8(8), .natural8(3)])),
        
        // MARK: Records
        ("record {}", .record()),
        (#"record {first_name = "John"; second_name = "Doe"}"#, .record([
            .init("first_name", .text("John")),
            .init("second_name", .text("Doe")),
        ])),
        (#"record { "name with spaces" = 42; "unicode, too: ☃" = true }"#, .record([
            .init("name with spaces", .natural(42)),
            .init("unicode, too: ☃", .bool(true)),
        ])),
        (#"record {"a"; "tuple"; null}"#, .record([
            .init(0, .text("a")),
            .init(1, .text("tuple")),
            .init(2, .null),
        ])),
        (#"record {b; 42: nat8}"#, .record([
            .init(0, .text("b")),
            .init(1, .natural8(42)),
        ])),
        
        // MARK: Variants
        ("variant { ok = 42 }", .variant(CandidKeyedItem("ok", .natural(42)))),
        (#"variant { "unicode, too: ☃" = true }"#, .variant(CandidKeyedItem("unicode, too: ☃", .bool(true)))),
        ("variant { fall }", .variant(CandidKeyedItem(0, .text("fall")))),
        ("variant { 42:nat8 }", .variant(CandidKeyedItem(0, .natural8(42)))),
        
        // MARK: Blobs
        ("blob hello", .blob(Data("hello".utf8))),
        (#"blob "hello""#, .blob(Data("hello".utf8))),
        
        // MARK: Services
        (#"service: "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae""#, try! .service("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae")),
        (#"service: "w7x7r-cok77-xa""#, try! .service("w7x7r-cok77-xa")),
        
        // MARK: Principals
        (#"principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae""#, try! .principal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae")),
        (#"principal "w7x7r-cok77-xa""#, try! .principal("w7x7r-cok77-xa")),
        
        // MARK: Functions
        (#"func "w7x7r-cok77-xa".hello"#, try! .function("w7x7r-cok77-xa", "hello")),
        (#"func "w7x7r-cok77-xa"."☃""#, try! .function("w7x7r-cok77-xa", "☃")),
        (#"func "aaaaa-aa".create_canister"#, try! .function("aaaaa-aa", "create_canister")),
    ]
    
    static let failingSingleValues: [(String, String)] = [
        ("","empty string"),
        (#"\u"#, "invalid text"),
        ("true2","unknown token"),
        ("nul","unknown token"),
        ("123_","number ending with _"),
        ("123__2","double _ in number"),
        ("0x","invalid hex number"),
        ("0x123G","invalid character in hex"),
        ("0x123_","hex number ending in _"),
        ("256:nat8", "overflow"),
        ("128:int8",  "overflow"),
        ("-129:int8", "underflow"),
        ("-1:nat8", "underflow"),
        ("+7:nat8", "naturals don't have sign"),
        ("opt", "no value for optional"),
        ("opt true:int8", "wrong type"),
        ("vec {8:nat8, 3}", "multiple types in vector"),
        (#"func "aaaaa-aa"create_canister"#, "no dot in function"),
        (#"func "aaaaa-aa",create_canister"#, "no dot in function"),
    ]
    
    /// https://raw.githubusercontent.com/internet-computer-protocol/evm-rpc-canister/main/providers.did
    static let realWorldEvm = """
(
    vec {
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "cloudflare-eth.com";
            primary = false;
            chainId = 1 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 0 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "rpc.ankr.com";
            primary = false;
            chainId = 1 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 1 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "ethereum-rpc.publicnode.com";
            primary = false;
            chainId = 1 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 2 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "ethereum.blockpi.network";
            primary = false;
            chainId = 1 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 3 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "rpc.sepolia.org";
            primary = false;
            chainId = 11_155_111 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 4 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "rpc.ankr.com";
            primary = false;
            chainId = 11_155_111 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 5 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "ethereum-sepolia.blockpi.network";
            primary = false;
            chainId = 11_155_111 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 6 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "ethereum-sepolia-rpc.publicnode.com";
            primary = false;
            chainId = 11_155_111 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 7 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "eth-mainnet.g.alchemy.com";
            primary = false;
            chainId = 1 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 8 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "eth-sepolia.g.alchemy.com";
            primary = false;
            chainId = 11_155_111 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 9 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "arb-mainnet.g.alchemy.com";
            primary = false;
            chainId = 42_161 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 10 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "rpc.ankr.com";
            primary = false;
            chainId = 42_161 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 11 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "arbitrum.blockpi.network";
            primary = false;
            chainId = 42_161 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 12 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "arbitrum-one-rpc.publicnode.com";
            primary = false;
            chainId = 42_161 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 13 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "base-mainnet.g.alchemy.com";
            primary = false;
            chainId = 42_161 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 14 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "rpc.ankr.com";
            primary = false;
            chainId = 42_161 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 15 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "base.blockpi.network";
            primary = false;
            chainId = 42_161 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 16 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "base-rpc.publicnode.com";
            primary = false;
            chainId = 8_453 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 17 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "opt-mainnet.g.alchemy.com";
            primary = false;
            chainId = 10 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 18 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "rpc.ankr.com";
            primary = false;
            chainId = 10 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 19 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "optimism.blockpi.network";
            primary = false;
            chainId = 10 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 20 : nat64;
        };
        record {
            cyclesPerCall = 0 : nat64;
            owner = principal "rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae";
            hostname = "optimism-rpc.publicnode.com\n";
            primary = false;
            chainId = 10 : nat64;
            cyclesPerMessageByte = 0 : nat64;
            providerId = 21 : nat64;
        };
    }
);
"""
}

//
//  CandidCodeGeneratorTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import XCTest
import Candid

final class CandidCodeGeneratorTests: XCTestCase {
    func testCodeGeneration() throws {
        let testVectors: [([String: CandidType], CandidInterfaceDefinition.ServiceDefinition?)] = [
            ([
                "ABool": .bool,
                "AData": .blob,
                "VectorBool": .vector(.bool),
                "VectorOptionalText": .vector(.option(.text)),
                "Record": .record(["a": .vector(.option(.integer)), "b": .natural, "c": .record([.bool, .text])]),
                "UnnamedType0": .record([.vector(.option(.integer8)), .natural8]),
                "RepeatedRecord": .record([.vector(.option(.integer8)), .natural8]),
                "Variant": .variant(["a": .null, "b": .text, "c": .record([.text, .integer]), "d": .record(["one": .bool, "two": .blob, "three": .record([.vector(.option(.integer8)), .natural8])])]),
                "UnnamedVariant": .variant("spring", "winter", "summer", "fall"),
                //"RecursiveRecord": .record(["recurse": .option(.named("RecursiveRecord"))])
            ],
             CandidInterfaceDefinition.ServiceDefinition(
                name: "TestService",
                signature: .concrete(.init([
                    .init("noArgsNoResults"),
                    .init("singleUnnamedArg", [.text], query: true),
                    .init("singleUnnamedResult", [], [.option(.bool)]),
                    .init("multipleUnnamedArgsAndResults", [.text, .vector(.natural)], [.option(.bool), .vector(.blob)]),
                    .init("multipleNamedArgsAndResults", 
                          [("name", .text), ("ids", .vector(.natural))],
                          [("out1", .option(.bool)), ("out2", .vector(.blob))]),
                ]))
             )
            )
        ]
        
        for (namedTypes, service) in testVectors {
            let interface = CandidInterfaceDefinition(namedTypes: namedTypes, service: service)
            let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: "TestCodeGeneration")
            print(generated)
        }
    }
    
    func testICRC7() async throws {
        let path = Bundle.module.url(forResource: "ICRC7", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let interface = try await CandidParser().parseInterfaceDescription(didFile)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: "ICRC7")
        print(generated)
    }
    
    func testGoldNFT() async throws {
        let path = Bundle.module.url(forResource: "GoldNFT", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let interface = try await CandidParser().parseInterfaceDescription(didFile)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: "GoldNFT")
        print(generated)
    }
    
    func testGenerateValue() throws {
        let testVectors: [CandidValue] = [
            .integer8(2),
            try! .vector([.integer8(1), .integer8(2), .integer8(3)]),
            .record(["a": .integer(3), "b": .option(.blob(Data.fromHex("DEADBEEF")!))]),
            .record([0: .integer(3), 1: .option(.blob(Data.fromHex("DEADBEEF")!))]),
            try! .variant(["a": .null, "b": .integer8], ("a", .null)),
            try! .variant(["a": .null, "b": .integer8], ("b", .integer8(2))),
            try! .variant(["a": .null, "b": .integer8, "c": .record([0:.bool, 1:.integer8])], ("c", .record([0:.bool(true), 1: .integer8(7)]))),
            try! .variant(["a": .null, "b": .integer8, "c": .record(["bool":.bool, "int8":.integer8])], ("c", .record(["bool":.bool(true), "int8": .integer8(7)]))),
        ]
        for input in testVectors {
            let generated = try CandidCodeGenerator().generateSwiftCode(for: input, valueName: "cValue")
            print(generated)
        }
    }
    
    func testGenerateValueDid() throws {
        let path = Bundle.module.url(forResource: "EVMProviders", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let parsed = try CandidParser().parseValue(didFile)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: parsed, valueName: "cValue")
        print(generated)
    }
}


import BigInt
struct UnnamedType0: Codable {
    let cyclesPerCall: UInt64
    let owner: CandidPrincipal
    let hostname: String
    let primary: Bool
    let chainId: UInt64
    let cyclesPerMessageByte: UInt64
    let providerId: UInt64
}

let cValue: [UnnamedType0] = [
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "cloudflare-eth.com",
        primary: false,
        chainId: 1,
        cyclesPerMessageByte: 0,
        providerId: 0
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "rpc.ankr.com",
        primary: false,
        chainId: 1,
        cyclesPerMessageByte: 0,
        providerId: 1
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "ethereum-rpc.publicnode.com",
        primary: false,
        chainId: 1,
        cyclesPerMessageByte: 0,
        providerId: 2
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "ethereum.blockpi.network",
        primary: false,
        chainId: 1,
        cyclesPerMessageByte: 0,
        providerId: 3
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "rpc.sepolia.org",
        primary: false,
        chainId: 11155111,
        cyclesPerMessageByte: 0,
        providerId: 4
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "rpc.ankr.com",
        primary: false,
        chainId: 11155111,
        cyclesPerMessageByte: 0,
        providerId: 5
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "ethereum-sepolia.blockpi.network",
        primary: false,
        chainId: 11155111,
        cyclesPerMessageByte: 0,
        providerId: 6
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "ethereum-sepolia-rpc.publicnode.com",
        primary: false,
        chainId: 11155111,
        cyclesPerMessageByte: 0,
        providerId: 7
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "eth-mainnet.g.alchemy.com",
        primary: false,
        chainId: 1,
        cyclesPerMessageByte: 0,
        providerId: 8
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "eth-sepolia.g.alchemy.com",
        primary: false,
        chainId: 11155111,
        cyclesPerMessageByte: 0,
        providerId: 9
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "arb-mainnet.g.alchemy.com",
        primary: false,
        chainId: 42161,
        cyclesPerMessageByte: 0,
        providerId: 10
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "rpc.ankr.com",
        primary: false,
        chainId: 42161,
        cyclesPerMessageByte: 0,
        providerId: 11
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "arbitrum.blockpi.network",
        primary: false,
        chainId: 42161,
        cyclesPerMessageByte: 0,
        providerId: 12
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "arbitrum-one-rpc.publicnode.com",
        primary: false,
        chainId: 42161,
        cyclesPerMessageByte: 0,
        providerId: 13
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "base-mainnet.g.alchemy.com",
        primary: false,
        chainId: 42161,
        cyclesPerMessageByte: 0,
        providerId: 14
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "rpc.ankr.com",
        primary: false,
        chainId: 42161,
        cyclesPerMessageByte: 0,
        providerId: 15
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "base.blockpi.network",
        primary: false,
        chainId: 42161,
        cyclesPerMessageByte: 0,
        providerId: 16
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "base-rpc.publicnode.com",
        primary: false,
        chainId: 8453,
        cyclesPerMessageByte: 0,
        providerId: 17
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "opt-mainnet.g.alchemy.com",
        primary: false,
        chainId: 10,
        cyclesPerMessageByte: 0,
        providerId: 18
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "rpc.ankr.com",
        primary: false,
        chainId: 10,
        cyclesPerMessageByte: 0,
        providerId: 19
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "optimism.blockpi.network",
        primary: false,
        chainId: 10,
        cyclesPerMessageByte: 0,
        providerId: 20
    )
    ,
    .init(
        cyclesPerCall: 0,
        owner: try! CandidPrincipal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
        hostname: "optimism-rpc.publicnode.com\n",
        primary: false,
        chainId: 10,
        cyclesPerMessageByte: 0,
        providerId: 21
    )
    ,
]


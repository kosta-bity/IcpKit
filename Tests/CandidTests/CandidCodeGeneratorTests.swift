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
    
    func testLedgerCanister() async throws {
        let path = Bundle.module.url(forResource: "LedgerCanister", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let interface = try await CandidParser().parseInterfaceDescription(didFile)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: "Ledger")
        print(generated)
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

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
        let namedTypes: [String: CandidType] = [
            "ABool": .bool,
            "AData": .blob,
            "VectorBool": .vector(.bool),
            "VectorOptionalText": .vector(.option(.text)),
            "Record": .record(["a": .vector(.option(.integer)), "b": .natural, "c": .record([.bool, .text])]),
            "UnnamedType0": .record([.vector(.option(.integer8)), .natural8]),
            "RepeatedRecord": .record([.vector(.option(.integer8)), .natural8]),
            "Variant": .variant(["a": .null, "b": .text, "c": .record([.text, .integer]), "d": .record(["one": .bool, "two": .blob, "three": .record([.vector(.option(.integer8)), .natural8])])]),
            "UnnamedVariant": .variant("spring", "winter", "summer", "fall"),
            "Function00": .function([CandidType](),[]),
            "Function01q": .function([],[.bool], query: true),
            "Function02": .function([],[.bool, .text]),
            "Function03q": .function([],[.bool, .text, .option(.bool)], query: true),
            "Function10": .function([.bool], []),
            "Function20": .function([.bool, .text], []),
            "Function30q": .function([.bool, .text, .option(.bool)], [], query: true),
            "TestServiceDef": .service([
                .init("foo", [.natural8], [.integer8]),
                .init(name: "ref", signatureReference: "Function01q")
            ]),
            //"RecursiveRecord": .record(["recurse": .option(.named("RecursiveRecord"))])
        ]
        let service = CandidInterfaceDefinition.ServiceDefinition(
            name: "TestService",
            signature: .concrete(.init([
                .init("noArgsNoResults"),
                .init("singleUnnamedArg", [.text], query: true),
                .init("singleUnnamedArgRecordWithUnnamedFields", [.record([.bool, .text])], []),
                .init("singleNamedArg", [("myString", .text)], [], query: true),
                .init("singleUnnamedResult", [], [.option(.bool)]),
                .init("singleNamedResult", [], [("myString", .text)], query: true),
                .init("multipleUnnamedArgsAndResults", [.text, .vector(.natural)], [.option(.bool), .vector(.blob)]),
                .init("multipleNamedArgsAndResults",
                      [("name", .text), ("ids", .vector(.natural))],
                      [("out1", .option(.bool)), ("out2", .vector(.blob))]),
                .init(name: "functionReference", signatureReference: "Function20"),
            ]))
        )
        
        let interface = CandidInterfaceDefinition(namedTypes: namedTypes, service: service)
        let generated = try CandidCodeGenerator(.init(generateHeader: false)).generateSwiftCode(for: interface, nameSpace: "TestCodeGeneration")
        let swiftPath = Bundle.module.url(forResource: "TestCodeGeneration", withExtension: "generated_swift")!
        let swiftFile = try String(contentsOf: swiftPath)
        XCTAssertEqual(generated, swiftFile)
    }
    
    func testLedgerCanister() async throws {
        let path = Bundle.module.url(forResource: "LedgerCanister", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let interface = try await CandidParser().parseInterfaceDescription(didFile)
        let generated = try CandidCodeGenerator(.init(generateHeader: false)).generateSwiftCode(for: interface, nameSpace: "Ledger")
        let swiftPath = Bundle.module.url(forResource: "LedgerCanister", withExtension: "generated_swift")!
        let swiftFile = try String(contentsOf: swiftPath)
        print(generated)
        XCTAssertEqual(generated, swiftFile)
    }
    
    func testICRC7() async throws {
        let path = Bundle.module.url(forResource: "ICRC7", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let interface = try await CandidParser().parseInterfaceDescription(didFile)
        let generated = try CandidCodeGenerator(.init(generateHeader: false)).generateSwiftCode(for: interface, nameSpace: "ICRC7")
        let swiftPath = Bundle.module.url(forResource: "ICRC7", withExtension: "generated_swift")!
        let swiftFile = try String(contentsOf: swiftPath)
        XCTAssertEqual(generated, swiftFile)
    }
    
    func testGoldNFT() async throws {
        let path = Bundle.module.url(forResource: "GoldNFT", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let interface = try await CandidParser().parseInterfaceDescription(didFile)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: "GoldNFT")
        print(generated)
    }
    
    func testGenerateValue() throws {
        let testVectors: [(CandidValue, String)] = [
            (.integer8(2), "let cValue: Int8 = 2"),
            (try! .vector([.integer8(1), .integer8(2), .integer8(3)]), "let cValue: [Int8] = [\n\t1,\n\t2,\n\t3,\n]\n"),
            (.record(["a": .integer(3), "b": .option(.blob(Data.fromHex("DEADBEEF")!))]), "struct UnnamedType0: Codable {\n\tlet a: BigInt\n\tlet b: Data?\n}\n\nlet cValue: UnnamedType0 = .init(\n\ta: 3,\n\tb: Data.fromHex(\"deadbeef\")!\n)"),
            (.record([0: .integer(3), 1: .option(.blob(Data.fromHex("DEADBEEF")!))]), """
let cValue: CandidTuple2<BigInt, Data?> = .init(
\t3,
\tData.fromHex("deadbeef")!
)
"""),
            (try! .variant(["a": .null, "b": .integer8], ("a", .null)), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)

\tenum CodingKeys: Int, CodingKey {
\t\tcase a = 97
\t\tcase b = 98
\t}
}

let cValue: UnnamedType0 = .a
"""),
            (try! .variant(["a": .null, "b": .integer8], ("b", .integer8(2))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)

\tenum CodingKeys: Int, CodingKey {
\t\tcase a = 97
\t\tcase b = 98
\t}
}

let cValue: UnnamedType0 = .b(2)
"""),
            (try! .variant(["a": .null, "b": .integer8, "c": .record([0:.bool, 1:.integer8])], ("c", .record([0:.bool(true), 1: .integer8(7)]))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)
\tcase c(Bool, Int8)

\tenum CodingKeys: Int, CodingKey {
\t\tcase a = 97
\t\tcase b = 98
\t\tcase c = 99
\t}
}

let cValue: UnnamedType0 = .c(true, 7)
"""),
            (try! .variant(["a": .null, "b": .integer8, "c": .record(["bool":.bool, "int8":.integer8])], ("c", .record(["bool":.bool(true), "int8": .integer8(7)]))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)
\tcase c(bool: Bool, int8: Int8)

\tenum CodingKeys: Int, CodingKey {
\t\tcase a = 97
\t\tcase b = 98
\t\tcase c = 99
\t}
}

let cValue: UnnamedType0 = .c(bool: true, int8: 7)
"""),
            (try! .function([], [.vector(.bool)], "aaaaa-aa", "foo"), "let cValue: ICPCallNoArgs<[Bool]> = .init(try! CandidPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [], "aaaaa-aa", "foo"), "let cValue: ICPCallNoResult<[Bool]> = .init(try! CandidPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [.vector(.bool)], "aaaaa-aa", "foo"), "let cValue: ICPCall<[Bool], [Bool]> = .init(try! CandidPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([], [.vector(.bool)], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQueryNoArgs<[Bool]> = .init(try! CandidPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQueryNoResult<[Bool]> = .init(try! CandidPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [.vector(.bool)], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQuery<[Bool], [Bool]> = .init(try! CandidPrincipal(\"aaaaa-aa\"), \"foo\")"),
        ]
        for (input, expected) in testVectors {
            let generated = try CandidCodeGenerator(.init(generateHeader: false)).generateSwiftCode(for: input, valueName: "cValue")
            XCTAssertEqual(generated, expected)
        }
    }
    
    func testGenerateValueDid() throws {
        let path = Bundle.module.url(forResource: "EVMProviders", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let parsed = try CandidParser().parseValue(didFile)
        let generated = try CandidCodeGenerator(.init(generateHeader: false)).generateSwiftCode(for: parsed, valueName: "cValue")
        let swiftPath = Bundle.module.url(forResource: "EVMProviders", withExtension: "generated_swift")!
        let swiftFile = try String(contentsOf: swiftPath)
        XCTAssertEqual(generated, swiftFile)
    }
}


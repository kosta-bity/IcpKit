//
//  CodeGeneratorTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import XCTest
import Candid
import CodeGenerator

final class CodeGeneratorTests: XCTestCase {
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
        let swiftPath = Bundle.module.url(forResource: "TestCodeGeneration", withExtension: "did.generated_swift")!
        let swiftFile = try String(contentsOf: swiftPath)
        XCTAssertEqual(generated, swiftFile)
    }
    
    func testTypeDidFiles() async throws {
        let testFiles: [String] = ["LedgerCanister", "ICRC7", "GoldNFT", "TestImports"]
        for file in testFiles {
            let did = file + ".did"
            let interface = try await CandidParser().parseInterfaceDescription(BundleDidProvider(main: did))
            let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: file)
            let swiftPath = Bundle.module.url(forResource: did, withExtension: "generated_swift")!
            let swiftFile = try String(contentsOf: swiftPath)
            XCTAssertEqual(generated, swiftFile)
        }
    }
    
    func testValueDidFiles() throws {
        let valueDidFiles = ["EVMProviders"]
        for valueDidFile in valueDidFiles {
            let path = Bundle.module.url(forResource: valueDidFile, withExtension: "did")!
            let didFile = try String(contentsOf: path)
            let parsed = try CandidParser().parseValue(didFile)
            let generated = try CandidCodeGenerator().generateSwiftCode(for: parsed, valueName: valueDidFile)
            let swiftPath = Bundle.module.url(forResource: valueDidFile, withExtension: "did.generated_swift")!
            let swiftFile = try String(contentsOf: swiftPath)
            XCTAssertEqual(generated, swiftFile)
        }
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

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t}
}

let cValue: UnnamedType0 = .a
"""),
            (try! .variant(["a": .null, "b": .integer8], ("b", .integer8(2))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t}
}

let cValue: UnnamedType0 = .b(2)
"""),
            (try! .variant(["a": .null, "b": .integer8, "c": .record([0:.bool, 1:.integer8])], ("c", .record([0:.bool(true), 1: .integer8(7)]))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)
\tcase c(Bool, Int8)

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t\tcase c
\t}
}

let cValue: UnnamedType0 = .c(true, 7)
"""),
            (try! .variant(["a": .null, "b": .integer8, "c": .record(["bool":.bool, "int8":.integer8])], ("c", .record(["bool":.bool(true), "int8": .integer8(7)]))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)
\tcase c(bool: Bool, int8: Int8)

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t\tcase c
\t}
\tenum CCodingKeys: String, CandidCodingKey {
\t\tcase bool
\t\tcase int8
\t}
}

let cValue: UnnamedType0 = .c(bool: true, int8: 7)
"""),
            (try! .function([], [.vector(.bool)], "aaaaa-aa", "foo"), "let cValue: ICPCallNoArgs<[Bool]> = .init(try! ICPPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [], "aaaaa-aa", "foo"), "let cValue: ICPCallNoResult<[Bool]> = .init(try! ICPPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [.vector(.bool)], "aaaaa-aa", "foo"), "let cValue: ICPCall<[Bool], [Bool]> = .init(try! ICPPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([], [.vector(.bool)], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQueryNoArgs<[Bool]> = .init(try! ICPPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQueryNoResult<[Bool]> = .init(try! ICPPrincipal(\"aaaaa-aa\"), \"foo\")"),
            (try! .function([.vector(.bool)], [.vector(.bool)], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQuery<[Bool], [Bool]> = .init(try! ICPPrincipal(\"aaaaa-aa\"), \"foo\")"),
        ]
        for (input, expected) in testVectors {
            let generated = try CandidCodeGenerator(.init(generateHeader: false)).generateSwiftCode(for: input, valueName: "cValue")
            XCTAssertEqual(generated, expected)
        }
    }
    
    func testIcrc7() async throws {
        // GoldNFT
        let service = try ICRC7.Service("io7gn-vyaaa-aaaak-qcbiq-cai")
        let collectionMetadata = try await service.icrc7_collection_metadata()
        let tokens = try await service.icrc7_tokens(prev: nil, take: nil)
        for metadata in collectionMetadata {
            print(metadata.tuple)
        }
        let token = tokens.first!
        print(token)
        let tokenMetadata = try await service.icrc7_token_metadata(token_ids: [token]).first!._1!
        guard case .Text(let text) = tokenMetadata._1 else {
            XCTFail()
            return
        }
        print(text)
    }
}

private class BundleDidProvider: CandidInterfaceDefinitionProvider {
    let main: String
    init(main: String) {
        self.main = main
    }
    
    func readMain() async throws -> String {
        try getBundle(main)
    }
    
    func read(contentsOf file: String) async throws -> String {
        try getBundle(file)
    }
    
    private func getBundle(_ name: String) throws -> String {
        let path = Bundle.module.url(forResource: name, withExtension: nil)!
        let didFile = try String(contentsOf: path)
        return didFile
    }
}

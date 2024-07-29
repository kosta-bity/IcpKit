//
//  CandidCodeGeneratorTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import XCTest
import IcpKit

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
            let generated = try CandidCodeGenerator().generateSwiftCode(for: interface)
            print(generated)
        }
    }
    
    func testRealDidFiles() async throws {
        let path = Bundle.module.url(forResource: "ICRC7", withExtension: "did")!
        let didFile = try String(contentsOf: path)
        let interface = try await CandidParser().parseInterfaceDescription(didFile)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, serviceName: "ICRC7Service")
        print(generated)
    }
}



import IcpKit
import BigInt

typealias ABool = Bool
typealias AData = Data
typealias RepeatedRecord = UnnamedType0
typealias UnnamedType0_0 = UnnamedType0
typealias VectorBool = [Bool]
typealias VectorOptionalText = [String?]

struct Record: GeneratedCandidType {
    let a: [BigInt?]
    let b: BigUInt
    let c: UnnamedType1
}

struct UnnamedType0: GeneratedCandidType {
    let _0: [Int8?]
    let _1: UInt8
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
    }
}

struct UnnamedType1: GeneratedCandidType {
    let _0: Bool
    let _1: String
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
    }
}

struct UnnamedType2: GeneratedCandidType {
    let _0: Bool?
    let _1: [Data]
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
    }
}

struct UnnamedType3: GeneratedCandidType {
    let out1: Bool?
    let out2: [Data]
}

enum UnnamedVariant: GeneratedCandidType {
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

enum Variant: GeneratedCandidType {
    case a
    case b(String)
    case c(String, BigInt)
    case d(one: Bool, two: Data, three: UnnamedType0)
    
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
    
    func noArgsNoResults() async throws {
        let method = ICPMethod(canister: canister,  methodName: "noArgsNoResults")
        _ = try await client.callAndPoll(method, effectiveCanister: canister)
    }
    
    func singleUnnamedArg(_ arg0: String) async throws {
        let method = ICPMethod(
            canister: canister,
            methodName: "singleUnnamedArg",
            args: try CandidEncoder().encode(arg0)
        )
        _ = try await client.callAndPoll(method, effectiveCanister: canister)
    }
    
    func singleUnnamedResult() async throws -> Bool? {
        let method = ICPMethod(canister: canister,  methodName: "singleUnnamedResult")
        let response = try await client.callAndPoll(method, effectiveCanister: canister)
        return try CandidDecoder().decode(response)
    }
    
    func multipleUnnamedArgsAndResults(_ arg0: String, _ arg1: [BigUInt]) async throws -> UnnamedType2 {
        let method = ICPMethod(
            canister: canister,
            methodName: "multipleUnnamedArgsAndResults",
            args: .record([
                0: try CandidEncoder().encode(arg0),
                1: try CandidEncoder().encode(arg1),
            ])
        )
        let response = try await client.callAndPoll(method, effectiveCanister: canister)
        return try CandidDecoder().decode(response)
    }
    
    func multipleNamedArgsAndResults(name: String, ids: [BigUInt]) async throws -> UnnamedType3 {
        let method = ICPMethod(
            canister: canister,
            methodName: "multipleNamedArgsAndResults",
            args: .record([
                0: try CandidEncoder().encode(name),
                1: try CandidEncoder().encode(ids),
            ])
        )
        let response = try await client.callAndPoll(method, effectiveCanister: canister)
        return try CandidDecoder().decode(response)
    }
    
}

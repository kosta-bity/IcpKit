//
//  CandidParserTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import XCTest
@testable import IcpKit

final class CandidParserTests: XCTestCase {
    let parser = CandidParser()
    
    func testParseType() throws {
        for (input, candidType) in CandidParserTestVectors.vectors {
            XCTAssertEqual(try parser.parseSingleType(input), candidType, "Failed \(input)\nNot equal to \(candidType.syntax)")
        }
    }
    
    func testParseTypeFunctionNames() throws {
        for (input, candidType, argNames, resNames) in CandidParserTestVectors.functionNames {
            let parsed = try parser.parseSingleType(input)
            XCTAssertEqual(parsed, candidType, "\(input)\nNot equal to \(candidType.syntax)")
            guard case .function(let signature) = parsed else {
                XCTFail("not a function")
                return
            }
            XCTAssertEqual(signature.arguments.map { $0.name }, argNames)
            XCTAssertEqual(signature.results.map { $0.name }, resNames)
        }
    }
    
    func testParseTypeFailing() throws {
        for input in CandidParserTestVectors.failing {
            XCTAssertThrowsError(try parser.parseSingleType(input), "\(input)")
        }
    }
    
    func testNamedTypes() throws {
        let did = try parser.parseInterfaceDescription(didFile)
        XCTAssertTrue(did.isResolved())
    }
}

let didFile = """
type A = nat;
type B = vec A;
type C = service { "foo": (A) -> (B); };
type stream = opt record {head : nat; next : func () -> (stream)};
type node = record {head : nat; tail : list};
type list = opt node;
service add: (A) -> C;
"""

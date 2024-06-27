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
            XCTAssertEqual(try parser.parseType(input), candidType, "Failed \(input)\nNot equal to \(candidType.syntax)")
        }
    }
    
    func testParseTypeFunctionNames() throws {
        for (input, candidType, argNames, resNames) in CandidParserTestVectors.functionNames {
            let parsed = try parser.parseType(input)
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
            XCTAssertThrowsError(try parser.parseType(input), "\(input)")
        }
    }
}

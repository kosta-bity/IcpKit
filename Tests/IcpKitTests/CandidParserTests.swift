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
    
    func testParseSingleTypes() throws {
        for (input, candidType) in CandidParserTestVectors.passingSingleTypes {
            XCTAssertEqual(try parser.parseSingleType(input), candidType, "Failed \(input)\nNot equal to \(candidType.syntax)")
        }
    }
    
    func testParseFunctionArgumentNames() throws {
        for (input, candidType, argNames, resNames) in CandidParserTestVectors.functionArgumentNames {
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
    
    func testParseFailingSingleType() throws {
        for input in CandidParserTestVectors.failingSingleTypes {
            XCTAssertThrowsError(try parser.parseSingleType(input), "\(input)")
        }
    }
    
    func testDidFiles() throws {
        for (did, namedTypes, service) in CandidParserTestVectors.didFiles {
            let interface = try parser.parseInterfaceDescription(did)
            XCTAssertEqual(interface.namedTypes, namedTypes)
            XCTAssertEqual(interface.service, service)
            XCTAssertTrue(interface.isResolved())
        }
    }
    
    func testUnresolvedDidFiles() throws {
        for did in CandidParserTestVectors.unresolvedDidFiles {
            let interface = try parser.parseInterfaceDescription(did)
            XCTAssertFalse(interface.isResolved(), did)
        }
    }
}

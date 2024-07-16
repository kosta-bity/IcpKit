//
//  CandidValueParserTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 12.07.24.
//

import XCTest
@testable import IcpKit

final class CandidValueParserTests: XCTestCase {
    private let parser = CandidValueParser()
    
    func testParsePrimValue() throws {
        for (string, expected) in CandidValueParserTestVectors.singleValueTests {
            let parsed = try parser.parseValue(string)
            XCTAssertEqual(parsed, expected, "\(parsed.description) is not equal to \(string)")
        }
    }
    
    func testFailingPrimValues() {
        for (string, reason) in CandidValueParserTestVectors.failingSingleValues {
            XCTAssertThrowsError(try parser.parseValue(string), "'\(string)' should fail because '\(reason)' but instead parsed \(try! parser.parseValue(string).description)")
        }
    }
    
    func testRealWorld() throws {
        let realWorld = CandidValueParserTestVectors.realWorldEvm
        let parsed = try parser.parseValue(realWorld)
        guard case .vector(let vector) = parsed else {
            XCTFail("not a vector")
            return
        }
        let first = vector.values.first!
        XCTAssertEqual(first, .record([
            "cyclesPerCall": .natural64(0),
            "owner": try .principal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
            "hostname": .text("cloudflare-eth.com"),
            "primary": .bool(false),
            "chainId": .natural64(1),
            "cyclesPerMessageByte": .natural64(0),
            "providerId": .natural64(0),
        ]))
        
        let last = vector.values.last!
        XCTAssertEqual(last, .record([
            "cyclesPerCall": .natural64(0),
            "owner": try .principal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
            "hostname": .text("optimism-rpc.publicnode.com\n"),
            "primary": .bool(false),
            "chainId": .natural64(10),
            "cyclesPerMessageByte": .natural64(0),
            "providerId": .natural64(21),
        ]))
    }
}

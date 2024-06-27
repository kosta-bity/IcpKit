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
    
    func testDidFiles() async throws {
        for (did, namedTypes, service) in CandidParserTestVectors.didFiles {
            let interface = try await parser.parseInterfaceDescription(did)
            XCTAssertEqual(interface.namedTypes, namedTypes)
            XCTAssertEqual(interface.service, service)
            XCTAssertTrue(interface.isResolved())
        }
    }
    
    func testUnresolvedDidFiles() async throws {
        for did in CandidParserTestVectors.unresolvedDidFiles {
            let interface = try await parser.parseInterfaceDescription(did)
            XCTAssertFalse(interface.isResolved(), did)
        }
    }
    
    func testFailingDidFiles() async throws {
        for did in CandidParserTestVectors.failingDidFiles {
            do {
                _ = try await parser.parseInterfaceDescription(did)
                XCTFail()
            } catch {
                // pass
            }
        }
    }
    
    func testImports() async throws {
        for (main, files, types, service) in CandidParserTestVectors.importedFiles {
            let provider = MockProvider(main, files)
            let interface = try await parser.parseInterfaceDescription(provider)
            XCTAssertEqual(interface.namedTypes, types)
            XCTAssertEqual(interface.service, service)
            XCTAssertTrue(interface.isResolved())
        }
    }
}

private class MockProvider: CandidInterfaceDefinitionProvider {
    let main: String
    let files: [String: String]
    init(_ main: String, _ files: [String : String]) {
        self.main = main
        self.files = files
    }
    
    func readMain() async throws -> String { main }
    
    func read(contentsOf file: String) async throws -> String {
        guard let contents = files[file] else { throw CandidParserError.unresolvedImport(file) }
        return contents
    }
}

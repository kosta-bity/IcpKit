//
//  CandidParser.swift
//
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation

class CandidParser {
    public func parseInterfaceDescription(_ provider: CandidInterfaceDefinitionProvider) async throws -> CandidInterfaceDefinition {
        try await CandidTypeParser().parseInterfaceDescription(provider)
    }
    
    public func parseInterfaceDescription(_ input: String) async throws -> CandidInterfaceDefinition {
        try await parseInterfaceDescription(CandidInterfaceDefinitionStringProvider(string: input))
    }
    
    public func parseSingleType(_ input: String) throws -> CandidType {
        try CandidTypeParser().parseSingleType(input)
    }
    
    public func parseValue(_ input: String) throws -> CandidValue {
        try CandidValueParser().parseValue(input)
    }
}

public enum CandidParserError: Error {
    case unrecognisedType(String)
    case unexpectedEnd
    case expecting(String, butGot: String)
    case unexpectedToken(String)
    case typeAlreadyDefined(String)
    case referencedTypeNotDefined(String)
    case unresolvedImport(String)
    case redundantService(String)
}

public protocol CandidInterfaceDefinitionProvider {
    func readMain() async throws -> String
    func read(contentsOf file: String) async throws -> String
}


// MARK: Private
class CandidInterfaceDefinitionStringProvider: CandidInterfaceDefinitionProvider {
    let string: String
    init(string: String) {
        self.string = string
    }
    
    func readMain() async throws -> String { string }
    func read(contentsOf file: String) async throws -> String {
        throw CandidParserError.unresolvedImport(file)
    }
}

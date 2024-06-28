//
//  CandidParserStream.swift
//
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation

class CandidParserStream {
    private (set) var tokens: [CandidParserToken]
    private (set) var current: CandidParserToken!
    
    init(string: String) throws {
        tokens = try Self.splitTokens(string)
    }
    
    func takeNext() throws -> CandidParserToken {
        guard !tokens.isEmpty else {
            throw CandidParserError.unexpectedEnd
        }
        current = tokens.removeFirst()
        return current
    }
    
    func expectNext(_ token: CandidParserToken) throws {
        let next = try takeNext()
        guard next == token else {
            throw CandidParserError.expecting(token.syntax, butGot: next.syntax)
        }
    }
    
    func peekNext() throws -> CandidParserToken {
        guard let token = tokens.first else {
            throw CandidParserError.unexpectedEnd
        }
        return token
    }
    
    func peekSecondNext() throws -> CandidParserToken {
        guard tokens.count > 1 else {
            throw CandidParserError.unexpectedEnd
        }
        return tokens[1]
    }
    
    func expectCurrentId() throws -> String {
        return try current.validId()
    }
    
    func expectCurrentTextOrId() throws -> String {
        return try current.textOrId()
    }
    
    func expectNextId() throws -> String {
        let token = try takeNext()
        return try token.validId()
    }
    
    func expectNextTextOrId() throws -> String {
        let token = try takeNext()
        return try token.textOrId()
    }
    
    func takeIfNext(is token: CandidParserToken) throws -> Bool {
        guard tokens.first == token else {
            return false
        }
        try expectNext(token)
        return true
    }
    
    static func splitTokens(_ string: String) throws -> [CandidParserToken] {
        var string = string
        var tokens: [CandidParserToken] = []
        while !string.isEmpty {
            tokens.append(try parseFirstToken(&string))
        }
        return tokens
    }
    
    private static func parseFirstToken( _ string: inout String) throws -> CandidParserToken {
        let match = try Self.firstToken.firstMatch(in: string)
        guard let token = match?["token"]?.substring else {
            throw CandidParserError.unexpectedEnd
        }
        string = String(match?["rest"]?.substring ?? Substring())
        return try CandidParserToken(String(token))
    }
    
    private static let firstToken = try! Regex(#"\s*(?'token'"[^"]*"|->|[={}\(\):;,]|[^\s={}\(\):;,]+)\s*(?'rest'[\s\S]*)"#)
}

private extension CandidParserToken {
    func textOrId() throws -> String {
        if case .id(let id) = self { return id }
        if case .text(let text) = self { return text }
        throw CandidParserError.expecting("<text|id>", butGot: syntax)
    }
    
    func validId() throws -> String {
        guard case .id(let id) = self,
              try Self.validIdRegex.firstMatch(in: id) != nil else {
            throw CandidParserError.expecting("<id>", butGot: syntax)
        }
        return id
    }
    
    private static let validIdRegex = try! Regex(#"[A-Za-z_][A-Za-z0-9]*"#)
}

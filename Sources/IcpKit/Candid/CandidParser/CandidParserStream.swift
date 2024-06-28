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
        guard case .id(let id) = current else {
            throw CandidParserError.expecting("<id>", butGot: current.syntax)
        }
        return id
    }
    
    func expectCurrentTextOrId() throws -> String {
        if case .id(let id) = current { return id }
        if case .text(let text) = current { return text }
        throw CandidParserError.expecting("<text>", butGot: current.syntax)
    }
    
    func expectNextId() throws -> String {
        let token = try takeNext()
        guard case .id(let id) = token else {
            throw CandidParserError.expecting("<id>", butGot: token.syntax)
        }
        return id
    }
    
    func expectNextTextOrId() throws -> String {
        let token = try takeNext()
        if case .id(let id) = token { return id }
        if case .text(let text) = token { return text }
        throw CandidParserError.expecting("<text>", butGot: token.syntax)
    }
    
    func takeIfNext(is token: CandidParserToken) throws -> Bool {
        guard tokens.first == token else {
            return false
        }
        try expectNext(token)
        return true
    }
    
    func prepend(_ newTokens: [CandidParserToken]) {
        tokens.insert(contentsOf: newTokens, at: 0)
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
    
    private static let firstToken = try! Regex(#"\s*(?'token'"[^"]*"|->|[={}\(\):;,]|[^\s:=;,\(\)}{]+)\s*(?'rest'[\s\S]*)"#)
}

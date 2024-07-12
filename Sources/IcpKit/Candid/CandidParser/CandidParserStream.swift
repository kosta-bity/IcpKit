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
        guard let match = try firstTokenRegex.firstMatch(in: string),
              let tokenGroup = match["token"],
              let token = tokenGroup.substring else {
            throw CandidParserError.unexpectedToken(string)
        }
        string = String(string[match.range.upperBound..<string.endIndex])
        return try CandidParserToken(String(token))
    }
    
    
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
    
    private static let validIdRegex = try! Regex(#"[A-Za-z_][A-Za-z0-9_]*"#)
}

private let whiteSpace = #"\s*"#
private let quotedString = #""[^"]*""#
private let arrow = "->"
private let singleCharToken = #"[={}\(\):;,]"#
private let anyString = #"[^={}\(\):;,\s]*"#
private let firstTokenRegex = try! Regex("^\(whiteSpace)(?'token'\(quotedString)|\(arrow)|\(singleCharToken)|\(anyString))\(whiteSpace)")

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
    
    func expectCurrentTextOrWord() throws -> String {
        return try current.textOrWord()
    }
    
    func expectNextId() throws -> String {
        let token = try takeNext()
        return try token.validId()
    }
    
    func expectNextWord() throws -> String {
        let token = try takeNext()
        return try token.word()
    }
    
    func expectNextTextOrWord() throws -> String {
        let token = try takeNext()
        return try token.textOrWord()
    }
    
    func takeIfNext(is token: CandidParserToken) throws -> Bool {
        guard tokens.first == token else {
            return false
        }
        try expectNext(token)
        return true
    }
    
    static let quotedStringContents = #"(?:[^"\\]|\\[nrt\\"']|\\[A-Fa-f0-9]{2}|\\u{[A-Fa-f0-9_]+)*"#
}

private extension CandidParserStream {
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
    
    private static let whiteSpace = #"\s*"#
    private static let arrow = "->"
    private static let singleCharToken = #"[={}\(\):;,]"#
    private static let quotedString = "\"\(quotedStringContents)\""
    private static let anyString = #"[^={}\(\):;,\"\s]+"#
    private static let firstTokenRegex = try! Regex("^\(whiteSpace)(?'token'\(quotedString)|\(arrow)|\(singleCharToken)|\(anyString))\(whiteSpace)")
}

private extension CandidParserToken {
    func word() throws -> String {
        if case .word(let id) = self { return id }
        throw CandidParserError.expecting("<word>", butGot: syntax)
    }
    
    func textOrWord() throws -> String {
        if case .word(let id) = self { return id }
        if case .text(let text) = self { return text }
        throw CandidParserError.expecting("<text|id>", butGot: syntax)
    }
    
    func validId() throws -> String {
        guard case .word(let id) = self,
              try Self.validIdRegex.firstMatch(in: id) != nil else {
            throw CandidParserError.expecting("<id>", butGot: syntax)
        }
        return id
    }
    
    private static let validIdRegex = try! Regex(#"[A-Za-z_][A-Za-z0-9_]*"#)
}



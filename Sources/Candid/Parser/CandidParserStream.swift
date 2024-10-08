//
//  CandidParserStream.swift
//
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation

class CandidParserStream {
    var hasNext: Bool {
        var iteratorCopy = iterator.makeIterator()
        return iteratorCopy.next() != nil
    }
    
    var hasAtLeastTwo: Bool {
        var iteratorCopy = iterator.makeIterator()
        return iteratorCopy.next() != nil && iteratorCopy.next() != nil
    }
    
    private var tokens: [CandidParsedRange]
    private var current: CandidParserToken!
    private var iterator: CommentSkippingIterator
    private let originalString: String
    private var lastMarker: String.Index?
    
    init(string: String) throws {
        originalString = string
        tokens = try Self.splitTokens(string)
        iterator = CommentSkippingIterator(tokens)
    }
    
    func originalStringSinceLastMarker() -> String {
        let start = lastMarker ?? originalString.startIndex
        guard let end = iterator.currentStringIndex, end >= start else {
            return ""
        }
        lastMarker = end
        return String(originalString[start..<end])
    }
    
    func setMarker() {
        lastMarker = iterator.currentStringIndex
    }
    
    func takeNext() throws -> CandidParserToken {
        guard let next = iterator.next() else {
            throw CandidParserError.unexpectedEnd
        }
        current = next
        return current
    }
    
    func expectNext(_ token: CandidParserToken) throws {
        let next = try takeNext()
        guard next == token else {
            throw CandidParserError.expecting(token.syntax, butGot: next.syntax)
        }
    }
    
    func peekNext() throws -> CandidParserToken {
        var iteratorCopy = iterator.makeIterator()
        guard let token = iteratorCopy.next() else {
            throw CandidParserError.unexpectedEnd
        }
        return token
    }
    
    func peekSecondNext() throws -> CandidParserToken {
        var iteratorCopy = iterator.makeIterator()
        guard let _ = iteratorCopy.next(),
              let next2 = iteratorCopy.next() else {
            throw CandidParserError.unexpectedEnd
        }
        return next2
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
        var iteratorCopy = iterator.makeIterator()
        guard iteratorCopy.next() == token else {
            return false
        }
        try expectNext(token)
        return true
    }
    
    static let quotedStringContents = #"(?:[^"\\]|\\[nrt\\"']|\\[A-Fa-f0-9]{2}|\\u{[A-Fa-f0-9_]+)*"#
}

private extension CandidParserStream {
    static func splitTokens(_ string: String) throws -> [CandidParsedRange] {
        var truncatedString = string
        var tokens: [CandidParsedRange] = []
        var lastIndex = string.startIndex
        while !truncatedString.isEmpty {
            let (token, length) = try parseFirstToken(&truncatedString)
            let index = string.index(lastIndex, offsetBy: length)
            let range = lastIndex..<index
            lastIndex = index
            tokens.append(CandidParsedRange(range: range, token: token))
            
        }
        return tokens
    }
    
    private static func parseFirstToken( _ string: inout String) throws -> (CandidParserToken, length: Int) {
        guard let match = try firstTokenRegex.firstMatch(in: string),
              let tokenGroup = match["token"],
              let token = tokenGroup.substring else {
            throw CandidParserError.unexpectedToken(string)
        }
        let length = string[match.range].count
        string = String(string[match.range.upperBound..<string.endIndex])
        let parserToken = try CandidParserToken(String(token))
        return (parserToken, length)
    }
    
    private static let commentSingleLine = #"\/\/[^\n]*($|\n)"#
    private static let commentMultiLine = #"\/\*[^*]*\*+(?:[^\/*][^*]*\*+)*\/"#
    private static let whiteSpace = #"\s*"#
    private static let arrow = "->"
    private static let singleCharToken = #"[={}\(\):;,]"#
    private static let quotedString = "\"\(quotedStringContents)\""
    private static let anyString = #"[^={}\(\):;,\"\s]+"#
    private static let firstTokenRegex = try! Regex("^\(whiteSpace)(?'token'\(quotedString)|\(arrow)|\(singleCharToken)|\(commentSingleLine)|\(commentMultiLine)|\(anyString))\(whiteSpace)")
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

private struct CommentSkippingIterator: IteratorProtocol {
    private let array: [CandidParsedRange]
    private var iterator: [CandidParsedRange].Iterator
    private(set) var currentStringIndex: String.Index?
    
    init(_ array: [CandidParsedRange]) {
        self.array = array
        self.iterator = array.makeIterator()
    }
    
    private init(_ array: [CandidParsedRange], _ iterator: [CandidParsedRange].Iterator) {
        self.array = array
        self.iterator = iterator
    }
    
    mutating func next() -> CandidParserToken? {
        var next = originalNext()
        while case .comment = next?.token {
            next = originalNext()
        }
        currentStringIndex = next?.range.upperBound
        return next?.token
    }
    
    mutating func originalNext() -> CandidParsedRange? {
        return iterator.next()
    }
    
    func makeIterator() -> CommentSkippingIterator {
        CommentSkippingIterator(array, iterator.makeIterator())
    }
}

//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import Foundation

enum CandidParserError: Error {
    case unrecognisedType(String)
    case unexpectedEnd
    case expecting(String, butGot: String)
    case unexpectedToken(String)
}

/// https://internetcomputer.org/docs/current/references/candid-ref#supported-types
class CandidParser {
    func parseType(_ input: String) throws -> CandidType {
        let stream = try CandidStringStream(string: input)
        return try parseType(stream)
    }
    
//    func parseValue(_ input: String) throws -> CandidValue {
//        throw CandidParserError.notImplemented
//    }
}

private extension CandidParser {
    func parseType(_ stream: CandidStringStream) throws -> CandidType {
        let token = try stream.takeNext()
        guard case .text(let type) = token else {
            throw CandidParserError.unrecognisedType(token.debugDescription)
        }
        switch type {
        case CandidPrimitiveType.null.syntax: return .null
        case CandidPrimitiveType.bool.syntax: return .bool
        case CandidPrimitiveType.natural.syntax: return .natural
        case CandidPrimitiveType.integer.syntax: return .integer
        case CandidPrimitiveType.natural8.syntax: return .natural8
        case CandidPrimitiveType.natural16.syntax: return .natural16
        case CandidPrimitiveType.natural32.syntax: return .natural32
        case CandidPrimitiveType.natural64.syntax: return .natural64
        case CandidPrimitiveType.integer8.syntax: return .integer8
        case CandidPrimitiveType.integer16.syntax: return .integer16
        case CandidPrimitiveType.integer32.syntax: return .integer32
        case CandidPrimitiveType.integer64.syntax: return .integer64
        case CandidPrimitiveType.float32.syntax: return .float32
        case CandidPrimitiveType.float64.syntax: return .float64
        case CandidPrimitiveType.text.syntax: return .text
        case CandidPrimitiveType.reserved.syntax: return .reserved
        case CandidPrimitiveType.empty.syntax: return .empty
        case CandidPrimitiveType.option.syntax: return .option(try parseType(stream))
        case CandidPrimitiveType.vector.syntax: return .vector(try parseType(stream))
        case CandidPrimitiveType.record.syntax: return .record(try parseRecordKeyedTypes(stream))
        case CandidPrimitiveType.variant.syntax: return .variant(try parseVariantKeyedTypes(stream))
        case CandidPrimitiveType.function.syntax: return .function(try parseFunctionSignature(stream))
            
        default:
            throw CandidParserError.unrecognisedType(token.debugDescription)
        }
    }
    
    // record {}
    // record { first_name : text; second_name : text }
    // record { "name with spaces" : nat; "unicode, too: ☃" : bool }
    // record { text; text; opt bool }
    private func parseRecordKeyedTypes(_ stream: CandidStringStream) throws -> [CandidKeyedItemType] {
        try stream.expectNext(.openBracket)
        var items: [CandidKeyedItemType] = []
        var unnamedItemCount = 0
        while try stream.peekNext() != .closeBracket {
            let key: String
            if try stream.peekSecondNext() == .colon {
                // key : type
                let keyToken = try stream.takeNext()
                guard let stringKey = keyToken.textValue else {
                    throw CandidParserError.expecting("anyString", butGot: keyToken.debugDescription)
                }
                key = stringKey
                try stream.expectNext(.colon)
            } else {
                // type only, use sequentially-increasing labels
                key = String(unnamedItemCount)
                unnamedItemCount += 1
            }
            
            let keyType = try parseType(stream)
            items.append(CandidKeyedItemType(key, keyType))
            if (try stream.peekNext() == .semicolon) {
                try stream.expectNext(.semicolon)
            }
        }
        try stream.expectNext(.closeBracket)
        return items
    }
    
    // variant {}
    // variant { ok : nat; error : text }
    // variant { "name with spaces" : nat; "unicode, too: ☃" : bool }
    // variant { spring; summer; fall; winter }
    private func parseVariantKeyedTypes(_ stream: CandidStringStream) throws -> [CandidKeyedItemType] {
        try stream.expectNext(.openBracket)
        var cases: [CandidKeyedItemType] = []
        var nextToken = try stream.takeNext()
        while nextToken != .closeBracket {
            guard let key = nextToken.textValue else {
                throw CandidParserError.expecting("anyString", butGot: nextToken.debugDescription)
            }
            nextToken = try stream.takeNext()
            if nextToken == .colon {
                let keyType = try parseType(stream)
                cases.append(CandidKeyedItemType(key, keyType))
                nextToken = try stream.takeNext()
            } else {
                cases.append(CandidKeyedItemType(key, .primitive(.null)))
            }
            if (nextToken == .semicolon) {
                nextToken = try stream.takeNext()
            }
        }
        return cases
    }
    
    // func () -> ()
    // func (text) -> (text)
    // func (dividend : nat, divisor : nat) -> (div : nat, mod : nat);
    // func () -> (int) query
    // func (func (int) -> ()) -> ()
    private func parseFunctionSignature(_ stream: CandidStringStream) throws -> CandidFunctionSignature {
        
        return CandidFunctionSignature(inputs: <#T##[CandidType]#>, outputs: <#T##[CandidType]#>, isQuery: <#T##Bool#>, isOneWay: <#T##Bool#>)
    }
}

private enum CandidParserToken: Equatable, CustomDebugStringConvertible {
    case text(String)         // text_without_spaces
    case quotedText(String)   // "quoted text with spaces"
    case openBracket
    case closeBracket
    case openParenthesis
    case closeParenthesis
    case semicolon
    case colon
    case equals
    
    var textValue: String? {
        switch self {
        case .text(let string), .quotedText(let string): return string
        default: return nil
        }
    }
    
    var debugDescription: String {
        switch self {
        case .text(let s), .quotedText(let s): return s
        case .openBracket: return "{"
        case .closeBracket: return "}"
        case .openParenthesis: return "("
        case .closeParenthesis: return ")"
        case .semicolon: return ";"
        case .colon: return ":"
        case .equals: return "="
        }
    }
    
    init(_ string: String) throws {
        switch string {
        case "{": self = .openBracket
        case "}": self = .closeBracket
        case "(": self = .openParenthesis
        case ")": self = .closeParenthesis
        case ":": self = .colon
        case ";": self = .semicolon
        case "=": self = .equals
        default:
            let match = try Self.quotedString.firstMatch(in: string)
            if let quoted = match?["string"]?.substring {
                self = .quotedText(String(quoted))
            } else {
                self = .text(string)
            }
        }
    }
    
    private static let quotedString = try! Regex(#""(?'string'[^"]*)""#)
}


private class CandidStringStream {
    private (set) var tokens: [CandidParserToken]
    
    init(string: String) throws {
        tokens = try Self.splitTokens(string)
    }
    
    func takeNext() throws -> CandidParserToken {
        guard !tokens.isEmpty else {
            throw CandidParserError.unexpectedEnd
        }
        return tokens.removeFirst()
    }
    
    func expectNext(_ token: CandidParserToken) throws {
        let next = try takeNext()
        guard next == token else {
            throw CandidParserError.expecting(token.debugDescription, butGot: next.debugDescription)
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
    
    private static func splitTokens(_ string: String) throws -> [CandidParserToken] {
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
    
    private static let firstToken = try! Regex(#"\s*(?'token'"[^"]*"|->|[={}\(\):;]|[^\s:=;\(\)}{]+)\s*(?'rest'[\s\S]*)"#)
}

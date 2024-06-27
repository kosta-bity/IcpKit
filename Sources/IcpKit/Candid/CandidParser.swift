//
//  CandidParser.swift
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
            throw CandidParserError.unrecognisedType(token.syntax)
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
        case CandidPrimitiveType.principal.syntax: return .principal
        case CandidPrimitiveType.service.syntax: return .service(try parseServiceSignature(stream))
        default:
            throw CandidParserError.unrecognisedType(token.syntax)
        }
    }
    
    // record {}
    // record { first_name : text; second_name : text }
    // record { "name with spaces" : nat; "unicode, too: ☃" : bool }
    // record { text; text; opt bool }
    private func parseRecordKeyedTypes(_ stream: CandidStringStream) throws -> [CandidKeyedItemType] {
        try stream.expectNext(.openBracket)
        let items = try parseOptionalNamedTypes(stream, .semicolon, .closeBracket)
            .map { CandidKeyedItemType($0.name ?? String($0.index), $0.type)}
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
                throw CandidParserError.expecting("anyString", butGot: nextToken.syntax)
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
        let inputs = try parseFunctionParameters(stream)
        try stream.expectNext(.rightArrow)
        let outputs = try parseFunctionParameters(stream)
        let query = try stream.takeIfNext(is: .text("query"))
        let oneway = try stream.takeIfNext(is: .text("oneway"))
        let compositeQuery = try stream.takeIfNext(is: .text("composite_query"))
        return CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneway, compositeQuery: compositeQuery)
    }
    
    // service address_book : {
    //     set_address: (name : text, addr : address) -> ();
    //     get_address: (name : text) -> (opt address) query;
    // }
    // service : {
    //    reverse : (text) -> (text);
    //    divMod : (dividend : nat, divisor : nat) -> (div : nat, mod : nat);
    // }
    // service : (InitArgs) -> {
    //    authorize : (principal, Auth) -> (success : bool);
    // };
    // type A = service { f : () -> () };
    private func parseServiceSignature(_ stream: CandidStringStream) throws -> CandidServiceSignature {
        let serviceName: String?
        if try stream.peekNext().textValue != nil {
            serviceName = try stream.takeNext().textValue!
        } else {
            serviceName = nil
        }
        try stream.expectNext(.colon)
        
        let initialisationParameters: [CandidFunctionSignature.Parameter]?
        if (try stream.peekNext() == .openParenthesis) {
            // ignore any service initialisation parameters. We can't use them from a mobile device
            initialisationParameters  = try parseFunctionParameters(stream)
            try stream.expectNext(.rightArrow)
        } else {
            initialisationParameters = nil
        }
        
        let methods = try parseServiceMethods(stream)
        return CandidServiceSignature(initialisationArguments: initialisationParameters, name: serviceName, methods: methods)
    }
    
    private func parseServiceMethods(_ stream: CandidStringStream) throws -> [CandidServiceSignature.Method] {
        try stream.expectNext(.openBracket)
        var token = try stream.takeNext()
        var methods: [CandidServiceSignature.Method] = []
        while token != .closeBracket {
            guard let methodName = token.textValue else {
                throw CandidParserError.expecting("anyString", butGot: token.syntax)
            }
            try stream.expectNext(.colon)
            let methodSignature = try parseFunctionSignature(stream)
            try stream.expectNext(.semicolon)
            token = try stream.takeNext()
            methods.append(.init(name: methodName, functionSignature: methodSignature))
        }
        return methods
    }
    
    private func parseOptionalNamedTypes(_ stream: CandidStringStream, _ separatorToken: CandidParserToken, _ closingToken: CandidParserToken) throws -> [CandidFunctionSignature.Parameter] {
        var parameters: [CandidFunctionSignature.Parameter] = []
        while try stream.peekNext() != closingToken {
            let name: String?
            if try stream.peekSecondNext() == .colon {
                // key : type
                let keyToken = try stream.takeNext()
                guard let stringKey = keyToken.textValue else {
                    throw CandidParserError.expecting("anyString", butGot: keyToken.syntax)
                }
                name = stringKey
                try stream.expectNext(.colon)
            } else {
                // type only, use sequentially-increasing labels
                name = nil
            }
            
            let keyType = try parseType(stream)
            parameters.append(CandidFunctionSignature.Parameter(index: parameters.count, name: name, type: keyType))
            if (try stream.peekNext() == separatorToken) {
                try stream.expectNext(separatorToken)
            }
        }
        try stream.expectNext(closingToken)
        return parameters
    }
    
    private func parseFunctionParameters(_ stream: CandidStringStream) throws -> [CandidFunctionSignature.Parameter] {
        try stream.expectNext(.openParenthesis)
        let parameters = try parseOptionalNamedTypes(stream, .comma, .closeParenthesis)
        return parameters
    }
}

private enum CandidParserToken: Equatable {
    case text(String)         // text_without_spaces
    case quotedText(String)   // "quoted text with spaces"
    case openBracket
    case closeBracket
    case openParenthesis
    case closeParenthesis
    case semicolon
    case colon
    case equals
    case comma
    case rightArrow
    
    var textValue: String? {
        switch self {
        case .text(let string), .quotedText(let string): return string
        default: return nil
        }
    }
    
    var syntax: String {
        switch self {
        case .text(let s): return s
        case .quotedText(let s): return "\"\(s)\""
        case .openBracket: return "{"
        case .closeBracket: return "}"
        case .openParenthesis: return "("
        case .closeParenthesis: return ")"
        case .semicolon: return ";"
        case .colon: return ":"
        case .equals: return "="
        case .comma: return ","
        case .rightArrow: return "->"
        }
    }
    
    init(_ string: String) throws {
        switch string {
        case Self.openBracket.syntax: self = .openBracket
        case Self.closeBracket.syntax: self = .closeBracket
        case Self.openParenthesis.syntax: self = .openParenthesis
        case Self.closeParenthesis.syntax: self = .closeParenthesis
        case Self.colon.syntax: self = .colon
        case Self.semicolon.syntax: self = .semicolon
        case Self.equals.syntax: self = .equals
        case Self.comma.syntax: self = .comma
        case Self.rightArrow.syntax:  self = .rightArrow
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
    
    func takeIfNext(is token: CandidParserToken) throws -> Bool {
        guard tokens.first == token else {
            return false
        }
        try expectNext(token)
        return true
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
    
    private static let firstToken = try! Regex(#"\s*(?'token'"[^"]*"|->|[={}\(\):;,]|[^\s:=;,\(\)}{]+)\s*(?'rest'[\s\S]*)"#)
}

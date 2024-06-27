//
//  CandidParser.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import Foundation

public enum CandidParserError: Error {
    case unrecognisedType(String)
    case unexpectedEnd
    case expecting(String, butGot: String)
    case unexpectedToken(String)
    case typeAlreadyDefined(String)
    case referencedTypeNotDefined(String)
}

/// https://internetcomputer.org/docs/current/references/candid-ref#supported-types
/// https://github.com/dfinity/candid/blob/master/spec/Candid.md
/// An interface description consists of a sequence of imports and type definitions, possibly followed by a service declaration. A service declaration names and specifies a service actor by specifying an actor type. The actor type may also be given by referring to the name of a type definition for an actor reference type.
/// The optional name given to the service in an interface description is immaterial; it only serves as documentation.
///
/// The Grammar used:
/// <prog>  ::= <def>;* <actor>?
/// <def>   ::= type <id> = <datatype> | import service? <text>
/// <actor> ::= service <id>? : (<tuptype> ->)? (<actortype> | <id>) ;?
///
/// <actortype> ::= { <methtype>;* }
/// <methtype>  ::= <name> : (<functype> | <id>)
/// <functype>  ::= <tuptype> -> <tuptype> <funcann>*
/// <funcann>   ::= oneway | query | composite_query
/// <tuptype>   ::= ( <argtype>,* )
/// <argtype>   ::= <datatype>
/// <fieldtype> ::= <nat> : <datatype>
/// <datatype>  ::= <id> | <primtype> | <comptype>
/// <comptype>  ::= <constype> | <reftype>
///
/// <primtype>  ::=
/// | <numtype>
/// | bool
/// | text
/// | null
/// | reserved
/// | empty
/// | principal
///
/// <numtype>  ::=
/// | nat | nat8 | nat16 | nat32 | nat64
/// | int | int8 | int16 | int32 | int64
/// | float32 | float64
///
/// <constype>  ::=
/// | opt <datatype>
/// | vec <datatype>
/// | record { <fieldtype>;* }
/// | variant { <fieldtype>;* }
///
/// <reftype>  ::=
/// | func <functype>
/// | service <actortype>
///
/// <name> ::= <id> | <text>
public class CandidParser {
    public init() {}
    
    func parseSingleType(_ input: String) throws -> CandidType {
        let stream = try CandidStringStream(string: input)
        return try parseCandidType(stream)
    }
    
    public func parseInterfaceDescription(_ input: String) throws -> CandidInterfaceDefinition {
        let stream = try CandidStringStream(string: input)
        let storage = NamedTypeStorage()
        while try !stream.tokens.isEmpty && stream.peekNext() != .text(CandidPrimitiveType.service.syntax) {
            if try stream.takeIfNext(is: .text("type")) {
                let (name, type) = try parseNamedType(stream)
                try storage.add(name, type)
                
            } else if try stream.takeIfNext(is: .text("import")) {
                throw CandidParserError.unexpectedToken("import")
                
            } else {
                throw CandidParserError.expecting("'type', 'import' or 'service'", butGot: try stream.takeNext().syntax)
            }
        }
        let service: CandidInterfaceDefinition.ServiceDefinition?
        if try stream.takeIfNext(is: .text(CandidPrimitiveType.service.syntax)) {
            service = try parseServiceDefinition(stream, storage)
        } else {
            service = nil
        }
        return CandidInterfaceDefinition(namedTypes: storage.namedTypes, service: service)
    }
    
//    func parseValue(_ input: String) throws -> CandidValue {
//        throw CandidParserError.notImplemented
//    }
}

private extension CandidParser {
    /// <def>   ::= type <id> = <datatype> | import service? <text>
    func parseNamedType(_ stream: CandidStringStream) throws -> (String, CandidType) {
        let nameToken = try stream.takeNext()
        guard let name = nameToken.textValue else {
            throw CandidParserError.expecting("type name", butGot: nameToken.syntax)
        }
        try stream.expectNext(.equals)
        let type = try parseCandidType(stream)
        try stream.expectNext(.semicolon)
        return (name, type)
    }
    
    func parseCandidType(_ stream: CandidStringStream) throws -> CandidType {
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
        case CandidPrimitiveType.principal.syntax: return .principal
        case CandidPrimitiveType.option.syntax: return .option(try parseCandidType(stream))
        case CandidPrimitiveType.vector.syntax: return .vector(try parseCandidType(stream))
        case CandidPrimitiveType.record.syntax: return .record(try parseRecordKeyedTypes(stream))
        case CandidPrimitiveType.variant.syntax: return .variant(try parseVariantKeyedTypes(stream))
        case CandidPrimitiveType.function.syntax: return .function(try parseFunctionSignature(stream))
        case CandidPrimitiveType.service.syntax: return .service(try parseServiceSignature(stream))
        default: return .named(type)
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
                let keyType = try parseCandidType(stream)
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
    
    /// func () -> ()
    /// func (text) -> (text)
    /// func (dividend : nat, divisor : nat) -> (div : nat, mod : nat);
    /// func () -> (int) query
    /// func (func (int) -> ()) -> ()
    ///
    /// func <functype>
    /// <functype>  ::= <tuptype> -> <tuptype> <funcann>*
    /// <funcann>   ::= oneway | query | composite_query
    /// <tuptype>   ::= ( <argtype>,* )
    private func parseFunctionSignature(_ stream: CandidStringStream) throws -> CandidFunctionSignature {
        let inputs = try parseFunctionParameters(stream)
        try stream.expectNext(.rightArrow)
        let outputs = try parseFunctionParameters(stream)
        let query = try stream.takeIfNext(is: .text("query"))
        let oneway = try stream.takeIfNext(is: .text("oneway"))
        let compositeQuery = try stream.takeIfNext(is: .text("composite_query"))
        return CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneway, compositeQuery: compositeQuery)
    }
    
    /// <actor> ::= service <id>? : (<tuptype> ->)? (<actortype> | <id>) ;?
    /// <actortype> ::= { <methtype>;* }
    private func parseServiceDefinition(_ stream: CandidStringStream, _ storage: NamedTypeStorage) throws -> CandidInterfaceDefinition.ServiceDefinition {
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
        
        let serviceSignature: CandidInterfaceDefinition.ServiceDefinition.SignatureType
        if try stream.peekNext() == .openBracket {
            serviceSignature = .concrete(try parseServiceSignature(stream))
        } else {
            let typeNameToken = try stream.takeNext()
            guard case .text(let typeName) = typeNameToken else {
                throw CandidParserError.expecting("service reference name", butGot: typeNameToken.syntax)
            }
            serviceSignature = .reference(typeName)
        }
        try stream.expectNext(.semicolon)
        
        return CandidInterfaceDefinition.ServiceDefinition(
            name: serviceName,
            initialisationArguments: initialisationParameters, 
            signature: serviceSignature)
    }
    
    /// service {
    ///     set_address: (name : text, addr : address) -> ();
    ///     get_address: (name : text) -> (opt address) query;
    /// }
    /// service {
    ///    reverse : (text) -> (text);
    ///    divMod : (dividend : nat, divisor : nat) -> (div : nat, mod : nat);
    /// }
    /// service {
    ///    authorize : (principal, Auth) -> (success : bool);
    /// };
    /// type A = service { f : () -> (); };
    /// type F = function () -> ();
    /// type S = service { foo: F; };
    ///
    /// <actortype> ::= { <methtype>;* }
    /// <methtype>  ::= <name> : (<functype> | <id>)
    private func parseServiceSignature(_ stream: CandidStringStream) throws -> CandidServiceSignature {
        try stream.expectNext(.openBracket)
        var token = try stream.takeNext()
        var methods: [CandidServiceSignature.Method] = []
        while token != .closeBracket {
            guard let methodName = token.textValue else {
                throw CandidParserError.expecting("anyString", butGot: token.syntax)
            }
            try stream.expectNext(.colon)
            let signatureType: CandidServiceSignature.Method.FunctionSignatureType
            if try stream.peekNext() == .openParenthesis {
                let methodSignature = try parseFunctionSignature(stream)
                signatureType = .concrete(methodSignature)
            } else {
                let nameToken = try stream.takeNext()
                guard case .text(let name) = nameToken else {
                    throw CandidParserError.expecting("method reference id", butGot: nameToken.syntax)
                }
                signatureType = .reference(name)
            }
            try stream.expectNext(.semicolon)
            token = try stream.takeNext()
            methods.append(.init(name: methodName, signatureType: signatureType))
        }
        return CandidServiceSignature(methods)
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
            
            let keyType = try parseCandidType(stream)
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

class NamedTypeStorage {
    private (set) var namedTypes: [String: CandidType] = [:]
    
    subscript (_ name: String) -> CandidType? {
        return namedTypes[name]
    }
    
    func add(_ name: String, _ type: CandidType) throws {
        guard !contains(name) else {
            throw CandidParserError.typeAlreadyDefined(name)
        }
        namedTypes[name] = type
    }
    
    func get(_ name: String) throws -> CandidType {
        guard let type = self[name] else {
            throw CandidParserError.referencedTypeNotDefined(name)
        }
        return type
    }
    
    func contains(_ name: String) -> Bool { namedTypes.keys.contains(name) }
}

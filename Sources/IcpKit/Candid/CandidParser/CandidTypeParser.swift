//
//  CandidParser.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import Foundation

/// https://internetcomputer.org/docs/current/references/candid-ref#supported-types
/// https://github.com/dfinity/candid/blob/master/spec/Candid.md
/// An interface description consists of a sequence of imports and type definitions, possibly followed by a service declaration. A service declaration names and specifies a service actor by specifying an actor type. The actor type may also be given by referring to the name of a type definition for an actor reference type.
/// The optional name given to the service in an interface description is immaterial; it only serves as documentation.
///
/// The Grammar used: https://github.com/dfinity/candid/blob/master/spec/Candid.md#core-grammar
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
public class CandidTypeParser {
    public init() {}
    
    public func parseSingleType(_ input: String) throws -> CandidType {
        let stream = try CandidParserStream(string: input)
        return try parseCandidType(stream)
    }
    
    public func parseInterfaceDescription(_ provider: CandidInterfaceDefinitionProvider) async throws -> CandidInterfaceDefinition {
        let mainContent = try await provider.readMain()
        let stream = try CandidParserStream(string: mainContent)
        return try await parseInterfaceDescription(provider, stream)
    }
}

private extension CandidTypeParser {
    func parseInterfaceDescription(_ provider: CandidInterfaceDefinitionProvider, _ stream: CandidParserStream) async throws -> CandidInterfaceDefinition {
        let context = ParsingContext()
        while try !stream.tokens.isEmpty && stream.peekNext() != .id(CandidPrimitiveType.service.syntax) {
            if try stream.takeIfNext(is: .id("type")) {
                let (name, type) = try parseNamedType(stream)
                try context.defineType(name, type)
                
            } else if try stream.takeIfNext(is: .id("import")) {
                try await parseImportStatement(stream, context, provider)
                
            } else {
                throw CandidParserError.expecting("'type', 'import' or 'service'", butGot: try stream.takeNext().syntax)
            }
        }
        if try stream.takeIfNext(is: .id(CandidPrimitiveType.service.syntax)) {
            let service = try parseServiceDefinition(stream)
            try context.setService(service)
        }
        return CandidInterfaceDefinition(namedTypes: context.namedTypes, service: context.service)
    }
    
    /// import service? <text>
    func parseImportStatement(_ stream: CandidParserStream, _ context: ParsingContext, _ provider: CandidInterfaceDefinitionProvider) async throws {
        let importService = try stream.takeIfNext(is: .id("service"))
        let fileName = try stream.expectNextTextOrId()
        try stream.expectNext(.semicolon)
        let fileContents = try await provider.read(contentsOf: fileName)
        let stream = try CandidParserStream(string: fileContents)
        let interface = try await parseInterfaceDescription(provider, stream)
        for type in interface.namedTypes {
            try context.defineType(type.key, type.value)
        }
        if importService, let service = interface.service {
            try context.setService(service)
        }
    }
    
    /// <def>   ::= type <id> = <datatype> | import service? <text>
    func parseNamedType(_ stream: CandidParserStream) throws -> (String, CandidType) {
        let name = try stream.expectNextId()
        try stream.expectNext(.equals)
        let type = try parseCandidType(stream)
        try stream.expectNext(.semicolon)
        return (name, type)
    }
    
    func parseCandidType(_ stream: CandidParserStream) throws -> CandidType {
        let type = try stream.expectNextId()
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
    private func parseRecordKeyedTypes(_ stream: CandidParserStream) throws -> [CandidKeyedItemType] {
        try stream.expectNext(.openBracket)
        let items = try parseOptionalNamedTypes(stream, .semicolon, .closeBracket)
            .map { CandidKeyedItemType($0.name ?? String($0.index), $0.type)}
        return items
    }
    
    // variant {}
    // variant { ok : nat; error : text }
    // variant { "name with spaces" : nat; "unicode, too: ☃" : bool }
    // variant { spring; summer; fall; winter }
    private func parseVariantKeyedTypes(_ stream: CandidParserStream) throws -> [CandidKeyedItemType] {
        try stream.expectNext(.openBracket)
        var cases: [CandidKeyedItemType] = []
        var nextToken = try stream.takeNext()
        while nextToken != .closeBracket {
            let key = try stream.expectCurrentTextOrId()
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
    private func parseFunctionSignature(_ stream: CandidParserStream) throws -> CandidFunctionSignature {
        let inputs = try parseFunctionParameters(stream)
        try stream.expectNext(.rightArrow)
        let outputs = try parseFunctionParameters(stream)
        let query = try stream.takeIfNext(is: .id("query"))
        let oneway = try stream.takeIfNext(is: .id("oneway"))
        let compositeQuery = try stream.takeIfNext(is: .id("composite_query"))
        return CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneway, compositeQuery: compositeQuery)
    }
    
    /// <actor> ::= service <id>? : (<tuptype> ->)? (<actortype> | <id>) ;?
    /// <actortype> ::= { <methtype>;* }
    private func parseServiceDefinition(_ stream: CandidParserStream) throws -> CandidInterfaceDefinition.ServiceDefinition {
        let serviceName: String?
        if try stream.peekNext().isTextOrId {
            serviceName = try stream.expectNextTextOrId()
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
            let typeName = try stream.expectNextId()
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
    private func parseServiceSignature(_ stream: CandidParserStream) throws -> CandidServiceSignature {
        try stream.expectNext(.openBracket)
        var token = try stream.takeNext()
        var methods: [CandidServiceSignature.Method] = []
        while token != .closeBracket {
            let methodName = try stream.expectCurrentTextOrId()
            try stream.expectNext(.colon)
            let signatureType: CandidServiceSignature.Method.FunctionSignatureType
            if try stream.peekNext() == .openParenthesis {
                let methodSignature = try parseFunctionSignature(stream)
                signatureType = .concrete(methodSignature)
            } else {
                let name = try stream.expectNextId()
                signatureType = .reference(name)
            }
            try stream.expectNext(.semicolon)
            token = try stream.takeNext()
            methods.append(.init(name: methodName, signatureType: signatureType))
        }
        return CandidServiceSignature(methods)
    }
    
    private func parseOptionalNamedTypes(_ stream: CandidParserStream, _ separatorToken: CandidParserToken, _ closingToken: CandidParserToken) throws -> [CandidFunctionSignature.Parameter] {
        var parameters: [CandidFunctionSignature.Parameter] = []
        while try stream.peekNext() != closingToken {
            let name: String?
            if try stream.peekSecondNext() == .colon {
                // key : type
                name = try stream.expectNextTextOrId()
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
    
    private func parseFunctionParameters(_ stream: CandidParserStream) throws -> [CandidFunctionSignature.Parameter] {
        try stream.expectNext(.openParenthesis)
        let parameters = try parseOptionalNamedTypes(stream, .comma, .closeParenthesis)
        return parameters
    }
}

private class ParsingContext {
    private (set) var namedTypes: [String: CandidType] = [:]
    private (set) var service: CandidInterfaceDefinition.ServiceDefinition?
    
    subscript (_ name: String) -> CandidType? {
        return namedTypes[name]
    }
    
    func defineType(_ name: String, _ type: CandidType) throws {
        guard !contains(name) else {
            throw CandidParserError.typeAlreadyDefined(name)
        }
        namedTypes[name] = type
    }
    
    func setService(_ service: CandidInterfaceDefinition.ServiceDefinition) throws {
        guard self.service == nil else {
            throw CandidParserError.redundantService(service.name ?? "(unnamed)")
        }
        self.service = service
    }
        
    func contains(_ name: String) -> Bool { namedTypes.keys.contains(name) }
}

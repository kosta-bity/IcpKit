//
//  CandidValueParser.swift
//
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation
import BigInt

/// https://github.com/dfinity/candid/blob/master/spec/Candid.md#values
/// <val> ::=
/// | <primval> | <consval> | <refval>
/// | ( <annval> )
///
/// <annval> ::=
/// | <val>
/// | <val> : <datatype>
///
/// <primval> ::=
/// | <nat> | <int> | <float>
/// | <text>
/// | true | false
/// | null
///
/// <consval> ::=
/// | opt <val>
/// | vec { <annval>;* }
/// | record { <fieldval>;* }
/// | variant { <fieldval> }
///
/// <fieldval> ::= <nat> = <annval>
///
/// <refval> ::=
/// | service <text>             (canister URI)
/// | func <text> . <name>       (canister URI and message name)
/// | principal <text>           (principal URI)
///
/// <arg> ::= ( <annval>,* )
///
/// <letter> ::= A..Z | a..z
/// <digit>  ::= 0..9
/// <id>     ::= (<letter> | _)(<letter> | <digit> | _)*
///
/// <sign>   ::= + | -
/// <hex>    ::= <digit> | A..F | a..f
/// <num>    ::= <digit>(_? <digit>)*
/// <hexnum> ::= <hex>(_? <hex>)*
/// <nat>    ::= <num> | 0x<hexnum>
/// <int>    ::= <sign>? <num>
/// <float>  ::=
/// | <sign>? <num> . <num>?
/// | <sign>? <num> (. <num>?)? (e | E) <sign>? <num>
/// | <sign>? 0x<hexnum> . <hexnum>?
/// | <sign>? 0x<hexnum> (. <hexnum>?)? (p | P) <sign>? <num>
///
/// <text>   ::= " <char>* "
/// <char>   ::=
/// | <utf8>
/// | \ <hex> <hex>
/// | \ <escape>
/// | \u{ <hexnum> }
/// <escape>  ::= n | r | t | \ | " | '
/// <utf8>    ::= <ascii> | <utf8enc>
/// <ascii>   ::= '\20'..'\7e' except " or \
/// <utf8enc> ::=
/// | '\c2'..'\df' <utf8cont>
/// | '\e0' '\a0'..'\bf' <utf8cont>
/// | '\ed' '\80'..'\9f' <utf8cont>
/// | '\e1'..'\ec' <utf8cont> <utf8cont>
/// | '\ee'..'\xef' <utf8cont> <utf8cont>
/// | '\f0' '\90'..'\bf' <utf8cont> <utf8cont>
/// | '\f4' '\80'..'\8f' <utf8cont> <utf8cont>
/// | '\f1'..'\f3' <utf8cont> <utf8cont> <utf8cont>
/// <utf8cont> ::= '\80'..'\bf'
class CandidValueParser: CandidParserBase {
    func parseValue(_ input: String) throws -> CandidValue {
        let stream = try CandidParserStream(string: input)
        return try Self.parseValue(stream)
    }
}

private extension CandidValueParser {
    /// <val> ::=
    /// | <primval> | <consval> | <refval>
    /// | ( <annval> )
    static func parseValue(_ stream: CandidParserStream) throws -> CandidValue {
        if try stream.takeIfNext(is: .openParenthesis) {
            let value = try parseValue(stream)
            try stream.expectNext(.closeParenthesis)
            return value
        }
        if let primValue = try parsePrimVal(stream) {
            if try stream.takeIfNext(is: .colon) {
                let dataTypeString = try stream.expectNextWord()
                let dataType = try parseDataType(dataTypeString)
                return try enforceTypeAnnotation(dataType, primValue)
            }
            return primValue
        }
        if let consValue = try parseConsVal(stream) {
            return consValue
        }
        if let refValue = try parseRefValue(stream) {
            return refValue
        }
        throw CandidParserError.unexpectedToken(try stream.peekNext().syntax)
    }
    
    /// <primval> ::=
    /// | <nat> | <int> | <float>
    /// | <text>
    /// | true | false
    /// | null
    /// <annval> ::=
    /// | <val>
    /// | <val> : <datatype>
    static func parsePrimVal(_ stream: CandidParserStream) throws -> CandidValue? {
        if case .text(let text) = try stream.peekNext() {
            _ = try stream.takeNext()
            return .text(text)
        }
        guard case .word(let word) = try stream.peekNext() else {
            return nil
        }
        if let null = tryParseNull(word) {
            _ = try stream.takeNext()
            return null
        }
        if let bool = tryParseBool(word) {
            _ = try stream.takeNext()
            return bool
        }
        if let number = try tryParseNumber(word) {
            _ = try stream.takeNext()
            return number
        }
        return nil
    }
    
    /// <consval> ::=
    /// | opt <val>
    /// | vec { <annval>;* }
    /// | blob <text>
    /// | record { <fieldval>;* }
    /// | variant { <fieldval> }
    static func parseConsVal(_ stream: CandidParserStream) throws -> CandidValue? {
        guard case .word(let word) = try stream.peekNext() else {
            return nil
        }
        switch word {
        case "opt":
            _ = try stream.takeNext()
            let value = try parseValue(stream)
            return .option(value)
            
        case "vec":
            _ = try stream.takeNext()
            let items = try parseEnclosedItems(.brackets, .semicolon, stream, parseValue)
            guard !items.isEmpty else {
                return .vector(.null)
            }
            return try .vector(items)
            
        case "blob":
            _ = try stream.takeNext()
            let text = try stream.expectNextTextOrWord()
            return .blob(Data(text.utf8))
            
        case "record":
            _ = try stream.takeNext()
            var index = 0
            let fieldValues = try parseEnclosedItems(.brackets, .semicolon, stream) {
                let fieldValue = try parseFieldValue($0, index)
                index += 1
                return fieldValue
            }
            return .record(fieldValues)
            
        case "variant":
            _ = try stream.takeNext()
            try stream.expectNext(.openBracket)
            let variantValue = try parseFieldValue(stream, 0)
            try stream.expectNext(.closeBracket)
            return .variant(variantValue)
            
        default: return nil
        }
    }
    
    /// <fieldval> ::= <nat> = <annval>
    private static func parseFieldValue(_ stream: CandidParserStream, _ index: Int) throws -> CandidKeyedValue {
        if stream.hasAtLeastTwo, try stream.peekSecondNext() == .equals {
            let key = try stream.expectNextTextOrWord()
            try stream.expectNext(.equals)
            let value = try parseValue(stream)
            if let intKey = Int(key) {
                return CandidKeyedValue(intKey, value)
            } else {
                return CandidKeyedValue(key, value)
            }
        } else {
            let value = try (try? parseValue(stream)) ?? .text(try stream.expectNextTextOrWord())
            return CandidKeyedValue(index, value)
        }
    }
    
    /// <refval> ::=
    /// | service <text>             (canister URI)
    /// | func <text> . <name>       (canister URI and message name)
    /// | principal <text>           (principal URI)
    static func parseRefValue(_ stream: CandidParserStream) throws -> CandidValue? {
        guard case .word(let word) = try stream.peekNext() else {
            return nil
        }
        switch word {
        case "service":
            _ = try stream.takeNext()
            try stream.expectNext(.colon)
            let principal = try stream.expectNextTextOrWord()
            return .service([], try CandidPrincipal(principal))
            
        case "func":
            _ = try stream.takeNext()
            let principal = try stream.expectNextTextOrWord()
            var method = try stream.expectNextTextOrWord()
            if method == "." {
                method = try stream.expectNextTextOrWord()
            } else if method.starts(with: ".") {
                method = String(method.suffix(from: method.index(after: method.startIndex)))
            } else {
                throw CandidParserError.unexpectedToken(method)
            }
            return .function([], [], try CandidPrincipal(principal), method)
            
        case "principal":
            _ = try stream.takeNext()
            let principal = try stream.expectNextTextOrWord()
            return try .principal(principal)
            
        default: return nil
        }
    }
}

// MARK: Null parsing
private extension CandidValueParser {
    static func tryParseNull(_ word: String) -> CandidValue? {
        guard word == "null" else { return nil }
        return .null
    }
}

// MARK: Bool parsing
private extension CandidValueParser {
    static func tryParseBool(_ word: String) -> CandidValue? {
        switch word {
        case "true": return .bool(true)
        case "false": return .bool(false)
        default: return nil
        }
    }
}

// MARK: Number parsing
private extension CandidValueParser {
    /// <digit>  ::= 0..9
    /// <sign>   ::= + | -
    /// <hex>    ::= <digit> | A..F | a..f
    
    /// <num>    ::= <digit>(_? <digit>)*
    /// <hexnum> ::= <hex>(_? <hex>)*
    /// <nat>    ::= <num> | 0x<hexnum>
    /// <int>    ::= <sign>? <nat>
    ///
    /// <float>  ::=
    /// | <sign>? <num> . <num>?
    /// | <sign>? <num> (. <num>?)? (e | E) <sign>? <num>
    /// | <sign>? 0x<hexnum> . <hexnum>?
    /// | <sign>? 0x<hexnum> (. <hexnum>?)? (p | P) <sign>? <num>
    static func tryParseNumber(_ word: String) throws -> CandidValue? {
        if let integerMatch = try integer10Regex.wholeMatch(in: word),
           let integerString = integerMatch.first?.substring?.replacing("_", with: ""),
           let integer = BigInt(integerString) {
            return .integer(integer)
            
        } else if let integerHexMatch = try integerHexRegex.wholeMatch(in: word),
                  let integerHexString = integerHexMatch.first?.substring?.replacing("_", with: "").replacing("0x", with: ""),
                  let integer = BigInt(integerHexString, radix: 16) {
            return .integer(integer)
            
        } else if let natural10Match = try natural10Regex.wholeMatch(in: word),
           let natural10String = natural10Match.first?.substring?.replacing("_", with: ""),
           let natural = BigUInt(natural10String) {
            return .natural(natural)
            
        } else if let naturalHexMatch = try naturalHexRegex.wholeMatch(in: word),
                  let naturalHexString = naturalHexMatch.first?.substring?.replacing("_", with: "").replacing("0x", with: ""),
                  let natural = BigUInt(naturalHexString, radix: 16) {
            return .natural(natural)
            
        } else if let float10Match = try float10ExpRegex.wholeMatch(in: word) ?? float10Regex.wholeMatch(in: word),
                  let float10String = float10Match.first?.substring?.replacing("_", with: ""),
                  let double = try? Double(String(float10String), format: .number) {
            return .float64(double)
            
        } else if let floatHexMatch = try floatHexExpRegex.wholeMatch(in: word) ?? floatHexRegex.wholeMatch(in: word),
                  let floatHexString = floatHexMatch.first?.substring?.replacing("_", with: "").replacing("0x", with: ""),
                  let splitMatch = try floatHexSplitRegex.wholeMatch(in: floatHexString),
                  let significandLString = splitMatch["significandL"]?.substring,
                  let significandL = BigInt(significandLString, radix: 16) {
            let significandR: BigUInt
            if let significandRString = splitMatch["significandR"]?.substring {
                guard let significandRBigUInt = BigUInt(significandRString, radix: 16) else {
                    throw CandidParserError.unexpectedToken(word)
                }
                significandR = significandRBigUInt
            } else {
                significandR = .zero
            }
            guard let significand = Decimal(string: "\(String(significandL)).\(String(significandR))") else {
                throw CandidParserError.unexpectedToken(word)
            }
            let exponent: Int
            if let exponentString = splitMatch["exponent"]?.substring {
                guard let expInt = Int(exponentString) else {
                    throw CandidParserError.unexpectedToken(word)
                }
                exponent = expInt
            } else {
                exponent = 0
            }
            let decimal = Decimal(sign: significandL.sign == .plus ? .plus : .minus, exponent: exponent, significand: significand)
            return .float64(Double(truncating: decimal as NSNumber))
        }
        return nil
    }
    
    private static let float10ExpRegex = try! Regex("[+-]?\(naturalNumber)(\\.(\(naturalNumber))?)?[eE][+-]?(\(naturalNumber))?")
    private static let float10Regex = try! Regex("[+-]?\(naturalNumber)\\.(\(naturalNumber))?")
    private static let floatHexRegex = try! Regex("[+-]?0x\(hexNumber)\\.(\(hexNumber))?")
    private static let floatHexExpRegex = try! Regex("[+-]?0x\(hexNumber)(\\.(\(hexNumber))?)?[pP][+-]?\(naturalNumber)")
    private static let floatHexSplitRegex = try! Regex("(?'significandL'[+-]?\(hex)+)\\.(?'significandR'\(hex)*)?[pP]?(?'exponent'[+-]?[0-9]+)?")
    private static let integer10Regex = try! Regex("[+-]\(naturalNumber)")
    private static let integerHexRegex = try! Regex("[+-]0x\(hexNumber)")
    private static let natural10Regex = try! Regex(naturalNumber)
    private static let naturalHexRegex = try! Regex("0x\(hexNumber)")
    private static let hex = "[A-Fa-f0-9]"
    private static let hexNumber = "\(hex)(_?\(hex))*"
    private static let naturalNumber = #"\d(_?\d)*"#
}

private extension CandidValueParser {
    static func parseDataType(_ dataType: String) throws -> CandidType {
        switch dataType {
        case "null": return .null
        case "bool": return .bool
        case "nat": return .natural
        case "nat8": return .natural8
        case "nat16": return .natural16
        case "nat32": return .natural32
        case "nat64": return .natural64
        case "int": return .integer
        case "int8": return .integer8
        case "int16": return .integer16
        case "int32": return .integer32
        case "int64": return .integer64
        case "float32": return .float32
        case "float64": return .float64
        case "text": return .text
            // TODO:
        default: throw CandidParserError.unrecognisedType(dataType)
        }
    }
    
    static func enforceTypeAnnotation(_ type: CandidType, _ value: CandidValue) throws -> CandidValue {
        switch type {
        case .null, .bool, .natural, .integer, .text:
            guard value.candidType == type else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return value
            
        case .natural8:
            guard let naturalValue = value.naturalValue,
                  naturalValue <= UInt8.max else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .natural8(UInt8(clamping: naturalValue))
            
        case .natural16:
            guard let naturalValue = value.naturalValue,
                  naturalValue <= UInt16.max else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .natural16(UInt16(clamping: naturalValue))
            
        case .natural32:
            guard let naturalValue = value.naturalValue,
                  naturalValue <= UInt32.max else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .natural32(UInt32(clamping: naturalValue))
            
        case .natural64:
            guard let naturalValue = value.naturalValue,
                  naturalValue <= UInt64.max else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .natural64(UInt64(clamping: naturalValue))
            
        case .integer8:
            guard let integerValue = value.integerOrNaturalValue,
                  integerValue <= Int8.max,
                  integerValue >= Int8.min else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .integer8(Int8(clamping: integerValue))
            
        case .integer16:
            guard let integerValue = value.integerOrNaturalValue,
                  integerValue <= Int16.max,
                  integerValue >= Int16.min else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .integer16(Int16(clamping: integerValue))
            
        case .integer32:
            guard let integerValue = value.integerOrNaturalValue,
                  integerValue <= Int32.max,
                  integerValue >= Int32.min else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .integer32(Int32(clamping: integerValue))
            
        case .integer64:
            guard let integerValue = value.integerOrNaturalValue,
                  integerValue <= Int64.max,
                  integerValue >= Int64.min else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .integer64(Int64(clamping: integerValue))
            
        case .float64:
            guard let floatingPoint = value.float64Value else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .float64(floatingPoint)
            
        case .float32:
            guard let floatingPoint = value.float64Value else {
                throw CandidParserError.nonConformingType(type, value)
            }
            return .float32(Float(truncating: floatingPoint as NSNumber))
            
        default:
            throw CandidParserError.nonConformingType(type, value)
        }
    }
}

private extension CandidValue {
    var integerOrNaturalValue: BigInt? {
        if let integerValue = self.integerValue {
            return integerValue
        } else if let naturalValue = self.naturalValue {
            return BigInt(naturalValue)
        }
        return nil
    }
}

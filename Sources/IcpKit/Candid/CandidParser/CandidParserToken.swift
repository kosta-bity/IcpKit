//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation

enum CandidParserToken: Equatable {
    case id(String)         // text_without_spaces
    case text(String)       // "quoted text with spaces and/or unicode"
    case openBracket
    case closeBracket
    case openParenthesis
    case closeParenthesis
    case semicolon
    case colon
    case equals
    case comma
    case rightArrow
    
    var isTextOrId: Bool {
        switch self {
        case .id, .text: return true
        default: return false
        }
    }
    
    var syntax: String {
        switch self {
        case .id(let s): return s
        case .text(let s): return "\"\(s)\""
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
            if let quotedStringMatch = try Self.quotedString.firstMatch(in: string),
               let quoted = quotedStringMatch["string"]?.substring {
                self = .text(String(quoted))
            } else {
                self = .id(string)
            }
        }
    }
    
    private static let quotedString = try! Regex(#""(?'string'[^"]*)""#)
}

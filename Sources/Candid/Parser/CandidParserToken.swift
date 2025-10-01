//
//  CandidParserToken.swift
//  
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation

struct CandidParsedRange {
    let range: Range<String.Index>
    let token: CandidParserToken
}

enum CandidParserToken: Equatable {
    case word(String)         // text_without_spaces
    case text(String)         // "quoted text with spaces and/or unicode"
    case openBracket
    case closeBracket
    case openParenthesis
    case closeParenthesis
    case semicolon
    case colon
    case equals
    case comma
    case rightArrow
    case comment(String, multiline: Bool)
    
    var isTextOrId: Bool {
        switch self {
        case .word, .text: return true
        default: return false
        }
    }
    
    var syntax: String {
        switch self {
        case .word(let word): return word
        case .text(let text): return "\"\(text)\""
        case .openBracket: return "{"
        case .closeBracket: return "}"
        case .openParenthesis: return "("
        case .closeParenthesis: return ")"
        case .semicolon: return ";"
        case .colon: return ":"
        case .equals: return "="
        case .comma: return ","
        case .rightArrow: return "->"
        case .comment(let comment, multiline: let multiline):
            if multiline { return "/*\(comment)*/"}
            return "//\(comment)\n"
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
        case Self.rightArrow.syntax: self = .rightArrow
        default:
            if let quotedStringMatch = try Self.quotedString.wholeMatch(in: string),
               let quoted = quotedStringMatch["string"]?.substring {
                self = .text(String(quoted))
                
            } else if let commentSingleLineMatch = try Self.singleLineComment.wholeMatch(in: string),
                      let comment = commentSingleLineMatch["comment"]?.substring {
                self = .comment(String(comment), multiline: false)
                
            } else if let commentMultiLineMatch = try Self.multiLineComment.wholeMatch(in: string),
                      let comment = commentMultiLineMatch["comment"]?.substring {
                self = .comment(String(comment), multiline: true)
                
            } else {
                self = .word(string)
            }
        }
    }
    
    nonisolated(unsafe) private static let quotedString = try! Regex("\"(?'string'\(CandidParserStream.quotedStringContents))\"")
    nonisolated(unsafe) private static let singleLineComment = try! Regex(#"\/\/(?'comment'[^\n]*)($|\n)"#)
    nonisolated(unsafe) private static let multiLineComment = try! Regex(#"\/\*(?'comment'[\s\S]*)\*\/"#)
}

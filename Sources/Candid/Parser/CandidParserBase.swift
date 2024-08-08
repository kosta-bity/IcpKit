//
//  CandidParserBase.swift
//
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation

class CandidParserBase {
    enum Enclosure {
        case parenthesis
        case brackets
    }
    enum Separator {
        case comma
        case semicolon
    }
    
    static func parseEnclosedItems<T>(_ enclosure: Enclosure, _ separator: Separator, _ stream: CandidParserStream, _ itemParser: (CandidParserStream) throws -> T) throws -> [T] {
        try stream.expectNext(enclosure.open)
        guard try stream.peekNext() != enclosure.close else {
            try stream.expectNext(enclosure.close)
            return []
        }
        var items: [T] = []
        while true {
            let item = try itemParser(stream)
            items.append(item)
            let token = try stream.takeNext()
            if token == separator.token {
                if try stream.peekNext() == enclosure.close {
                    try stream.expectNext(enclosure.close)
                    break
                }
                continue
            } else if token == enclosure.close {
                break
            } else {
                throw CandidParserError.expecting("'\(separator.token.syntax)' or '\(enclosure.close.syntax)'", butGot: token.syntax)
            }
        }
        return items
    }
}

private extension CandidParserBase.Enclosure {
    var open: CandidParserToken {
        switch self {
        case .parenthesis: return .openParenthesis
        case .brackets: return .openBracket
        }
    }
    
    var close: CandidParserToken {
        switch self {
        case .parenthesis: return .closeParenthesis
        case .brackets: return .closeBracket
        }
    }
}

private extension CandidParserBase.Separator {
    var token: CandidParserToken {
        switch self {
        case .comma: return .comma
        case .semicolon: return .semicolon
        }
    }
}

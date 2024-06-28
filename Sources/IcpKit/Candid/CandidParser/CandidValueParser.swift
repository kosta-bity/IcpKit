//
//  CandidValueParser.swift
//
//
//  Created by Konstantinos Gaitanis on 28.06.24.
//

import Foundation

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
/// | <sign>? <num> (. <frac>?)? (e | E) <sign>? <num>
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
        return try parseValue(stream)
    }
}

private extension CandidValueParser {
    func parseValue(_ stream: CandidParserStream) throws -> CandidValue {
        
        return .null
    }
}

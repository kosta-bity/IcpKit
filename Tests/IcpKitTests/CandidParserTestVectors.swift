//
//  CandidParserTestVectors.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation
import IcpKit

enum CandidParserTestVectors {
    static let vectors: [(String, CandidType)] = [
        ("null", .null),
        ("bool", .bool),
        ("nat", .natural),
        ("int", .integer),
        ("nat8", .natural8),
        ("nat16", .natural16),
        ("nat32", .natural32),
        ("nat64", .natural64),
        ("int8", .integer8),
        ("int16", .integer16),
        ("int32", .integer32),
        ("int64", .integer64),
        ("float32", .float32),
        ("float64", .float64),
        ("text", .text),
        ("reserved", .reserved),
        ("empty", .empty),
        ("principal", .principal),
        ("null ignored", .null),
        ("  null ignored", .null),
        ("\n\tnull", .null),
        
        ("opt null", .option(.null)),
        ("opt nat8", .option(.natural8)),
        ("opt text", .option(.text)),
        
        ("vec int", .vector(.integer)),
        ("vec opt nat8", .vector(.option(.natural8))),
        ("vec vec text", .vector(.vector(.text))),
        ("  vec\tint  ", .vector(.integer)),
        ("\n\tvec\tint  ", .vector(.integer)),
        
        ("variant {}", .variant()),
        ("variant { ok : nat; error : text }", .variant(["ok": .natural, "error": .text])),
        ("variant { ok : vec nat8 }", .variant(["ok": .vector(.natural8)])),
        (#"variant { "name with spaces" : nat; "unicode, too: ☃" : bool }"#, .variant(["name with spaces": .natural, "unicode, too: ☃": .bool])),
        ("variant { spring; summer; fall; winter }", .variant(["spring": .null, "summer": .null, "fall": .null, "winter": .null])),
        (#"variant { "vec nat 8" : variant {} }"#, .variant(["vec nat 8": .variant()])),
        ("variant{v:variant{}}", .variant(["v": .variant()])),
        
        ("record {}", .record()),
        ("record { first_name : text; text : text }", .record(["first_name": .text, "text": .text])),
        (#"record { "name with spaces" : nat; "unicode, too: ☃" : bool }"#, .record(["name with spaces": .natural, "unicode, too: ☃": .bool])),
        ("record { text; text; opt bool }", .record(["0": .text, "1": .text, "2": .option(.bool)])),
        (#"record{record{opt bool};"key":text;}"#, .record(["0": .record(["0": .option(.bool)]), "key": .text])),
        
        ("func () -> ()", .function()),
        ("func () -> () oneway", .function(oneWay: true)),
        ("func (text, opt bool) -> (text)", .function([.text, .option(.bool)], [.text])),
        ("func () -> (int) query", .function([], [.integer], query: true)),
        ("func (func (int) -> ()) -> ()", .function([.function([.integer], [])], [])),
        
        ("service {}", .service()),
        ("service { search : (query : text, callback : func (vec nat) -> ()) -> (); }",
            .service([
                .init("search", [("query", .text), ("callback", .function([.vector(.natural)], []))],[])
            ])),
        ("service { set_address: (name : text, addr : nat) -> (); get_address: (name : text) -> (opt nat) query; }",
            .service([
                .init("set_address", [("name", .text), ("addr", .natural)], []),
                .init("get_address", [("name", .text)], [(nil, .option(.natural))], query: true),
            ])),
    ]
    
    static let functionNames: [(String, CandidType, [String], [String])] = [
        ("func (dividend : nat, divisor : nat) -> (div : nat, mod : nat);", .function([.natural, .natural], [.natural, .natural]), ["dividend", "divisor"], ["div", "mod"]),
        (#"func ("dividend with space" : nat, "divisor" : nat) -> ("🐂" : nat, mod : nat);"#, .function([.natural, .natural], [.natural, .natural]), ["dividend with space", "divisor"], ["🐂", "mod"]),
    ]
    
    static let failing: [String] = [
        "",
        "\t",
        " ",
        "opt",
        "opt vec",
    ]
    
//     ("service foo: {}", .service("foo")),
//     ("service address_book : { set_address: (name : text, addr : nat) -> (); get_address: (name : text) -> (opt nat) query; }",
//        .service("address_book", [
//            .init("set_address", [("name", .text), ("addr", .natural)], []),
//            .init("get_address", [("name", .text)], [(nil, .option(.natural))], query: true),
//        ])),
//    ("service : (text) -> {}", .service(nil, [.init(index: 0, name: nil, type: .text)], [])),
//    ("service foo : (arg:text) -> {}", .service("foo", [.init(index: 0, name: "arg", type: .text)], []))
}

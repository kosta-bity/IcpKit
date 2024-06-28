//
//  CandidTypeParserTestVectors.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation
@testable import IcpKit

enum CandidTypeParserTestVectors {
    static let passingSingleTypes: [(String, CandidType)] = [
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
    
    static let functionArgumentNames: [(String, CandidType, [String], [String])] = [
        ("func (dividend : nat, divisor : nat) -> (div : nat, mod : nat);", .function([.natural, .natural], [.natural, .natural]), ["dividend", "divisor"], ["div", "mod"]),
        (#"func ("dividend with space" : nat, "divisor" : nat) -> ("🐂" : nat, mod : nat);"#, .function([.natural, .natural], [.natural, .natural]), ["dividend with space", "divisor"], ["🐂", "mod"]),
    ]
    
    static let failingSingleTypes: [String] = [
        "",
        "\t",
        " ",
        "opt",
        "opt vec",
    ]
    
    static let didFiles: [(String, [String: CandidType], CandidInterfaceDefinition.ServiceDefinition?)] = [
        ("", [:], nil),
        ("type A = nat;", ["A": .natural], nil),
        ("type A = nat;type B = vec A;", ["A": .natural, "B": .vector(.named("A"))], nil),
        ("type stream = opt record {head : nat; next : func () -> (stream)};", ["stream": .option(.record([
            .init("head", .natural), .init("next", .function([], [.named("stream")]))
        ]))], nil),
        ("type node = record {head : nat; tail : list};type list = opt node;", [
            "node": .record([.init("head", .natural), .init("tail", .named("list"))]),
            "list": .option(.named("node")),
        ], nil),
        (#"type A = nat;type B = vec A;type C = service { "foo": (A) -> (B); };"#, [
            "A": .natural,
            "B": .vector(.named("A")),
            "C": .service([.init("foo", [.named("A")], [.named("B")])])
        ], nil),
        ("service: {};", [:], .init(name: nil, initialisationArguments: nil, signature: .init([]))),
        ("service:(nat)-> {};", [:], .init(name: nil, initialisationArguments: [.init(index: 0, name: nil, type: .natural)], signature: .init([]))),
        ("service:()-> {};", [:], .init(name: nil, initialisationArguments: [], signature: .init([]))),
        ("service:(nat:nat)-> {};", [:], .init(name: nil, initialisationArguments: [.init(index: 0, name: "nat", type: .natural)], signature: .init([]))),
        ("service add:(nat)-> {foo: ()->()query;};", [:], .init(name: "add", initialisationArguments: [.init(index: 0, name: nil, type: .natural)], signature: .init([.init("foo", query: true)]))),
        ("type s = service{};service: s;", ["s":.service()], .init(name: nil, initialisationArguments: nil, signatureReference: "s")),
        ("type s = service{};service foo: (nat)-> s;", ["s":.service()], .init(name: "foo", initialisationArguments: [.init(index: 0, name: nil, type: .natural)], signatureReference: "s")),
        ("type f=func ()->();type s=service{foo:f;};", ["f":.function(), "s":.service([.init(name: "foo", signatureReference: "f")])], nil)
    ]
    
    static let unresolvedDidFiles: [String] = [
        "type B = vec A;",
        "type B = A;",
        "type B = record { a: A };",
        "type B = func (A) -> ();",
        "type B = func () -> (A);",
        "type B = service { foo: (A) -> (); };",
        "service: B;",
        "type A = nat; service: A;",
        "service: (B) -> {};",
        "service: { foo: (B) -> (); };",
    ]
    
    static let failingDidFiles: [String] = [
        "type B = nat; type B = opt nat;",
        "type A = nat", // no ending semi-colon
    ]
    
    static let importedFiles: [(mainDid: String, files: [String: String], types: [String: CandidType], CandidInterfaceDefinition.ServiceDefinition?)] = [
        ("import file1.did;", ["file1.did": "type A=nat;"], ["A":.natural], nil),
        ("import file1.did;type B = opt A;", ["file1.did": "type A=nat;"], ["A":.natural, "B": .option(.named("A"))], nil),
        ("type B = opt A;import file1.did;", ["file1.did": "type A=nat;"], ["A":.natural, "B": .option(.named("A"))], nil),
        ("import file1.did;", ["file1.did": "type A=nat;service: {};"], ["A":.natural], nil),
        ("import file1.did;", ["file1.did": "type A=nat;service add: {};"], ["A":.natural], nil),
        ("import service file1.did;", ["file1.did": "type A=nat;service: {};"], ["A":.natural], .init(name: nil, initialisationArguments: nil, signature: .init([]))),
        ("import service file1.did;", ["file1.did": "type A=nat;service add: {};"], ["A":.natural], .init(name: "add", initialisationArguments: nil, signature: .init([]))),
        ("import file1.did;service sub: S;", ["file1.did": "type A=nat;type S=service{};service add: {};"], ["A":.natural, "S":.service()], .init(name: "sub", initialisationArguments: nil, signatureReference: "S")),
        ("import service file1.did;type B=nat;", ["file1.did": "type A=nat;service add: {};"], ["A":.natural, "B":.natural], .init(name: "add", initialisationArguments: nil, signature: .init([]))),
    ]
    
    static let failingImportedFiles: [(mainDid: String, files: [String:String])] = [
        ("import file1", [:]),  // file not found
        ("import service file1;service: {}", ["file1":"service: {}"]) // 2 services
    ]
}

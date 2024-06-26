//
//  CandidParserTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import XCTest
@testable import IcpKit

final class CandidParserTests: XCTestCase {
    let parser = CandidParser()
    
    func testSimpleTypes() throws {
        XCTAssertEqual(try parser.parseType("null"), .null)
        XCTAssertEqual(try parser.parseType("bool"), .bool)
        XCTAssertEqual(try parser.parseType("nat"), .natural)
        XCTAssertEqual(try parser.parseType("int"), .integer)
        XCTAssertEqual(try parser.parseType("nat8"), .natural8)
        XCTAssertEqual(try parser.parseType("nat16"), .natural16)
        XCTAssertEqual(try parser.parseType("nat32"), .natural32)
        XCTAssertEqual(try parser.parseType("nat64"), .natural64)
        XCTAssertEqual(try parser.parseType("int8"), .integer8)
        XCTAssertEqual(try parser.parseType("int16"), .integer16)
        XCTAssertEqual(try parser.parseType("int32"), .integer32)
        XCTAssertEqual(try parser.parseType("int64"), .integer64)
        XCTAssertEqual(try parser.parseType("float32"), .float32)
        XCTAssertEqual(try parser.parseType("float64"), .float64)
        XCTAssertEqual(try parser.parseType("text"), .text)
        XCTAssertEqual(try parser.parseType("reserved"), .reserved)
        XCTAssertEqual(try parser.parseType("empty"), .empty)
        
        XCTAssertThrowsError(try parser.parseType(""))
        XCTAssertThrowsError(try parser.parseType("\t"))
        XCTAssertThrowsError(try parser.parseType(" "))
        XCTAssertThrowsError(try parser.parseType("unknown"))
        
        XCTAssertEqual(try parser.parseType("null ignored"), .null)
        XCTAssertEqual(try parser.parseType("  null ignored"), .null)
        XCTAssertEqual(try parser.parseType("\n\tnull"), .null)
    }
    
    func testContainedTypes() throws {
        XCTAssertEqual(try parser.parseType("opt null"), .option(.null))
        XCTAssertEqual(try parser.parseType("opt nat8"), .option(.natural8))
        XCTAssertEqual(try parser.parseType("opt text"), .option(.text))
        
        XCTAssertEqual(try parser.parseType("vec int"), .vector(.integer))
        XCTAssertEqual(try parser.parseType("vec opt nat8"), .vector(.option(.natural8)))
        XCTAssertEqual(try parser.parseType("vec vec text"), .vector(.vector(.text)))
        
        XCTAssertThrowsError(try parser.parseType("opt"))
        XCTAssertThrowsError(try parser.parseType("opt vec"))
        XCTAssertThrowsError(try parser.parseType("opt unknown"))
        
        XCTAssertEqual(try parser.parseType("  vec\tint  "), .vector(.integer))
        XCTAssertEqual(try parser.parseType("\n\tvec\tint  "), .vector(.integer))
    }
    
    func testVariantType() throws {
        XCTAssertEqual(try parser.parseType("variant {}"), .variant())
        XCTAssertEqual(try parser.parseType("variant { ok : nat; error : text }"), .variant(["ok": .natural, "error": .text]))
        XCTAssertEqual(try parser.parseType("variant { ok : vec nat8 }"), .variant(["ok": .vector(.natural8)]))
        XCTAssertEqual(try parser.parseType(#"variant { "name with spaces" : nat; "unicode, too: ☃" : bool }"#), .variant(["name with spaces": .natural, "unicode, too: ☃": .bool]))
        XCTAssertEqual(try parser.parseType("variant { spring; summer; fall; winter }"), .variant(["spring": .null, "summer": .null, "fall": .null, "winter": .null]))
        XCTAssertEqual(try parser.parseType(#"variant { "vec nat 8" : variant {} }"#), .variant(["vec nat 8": .variant()]))
        XCTAssertEqual(try parser.parseType(#"variant{v:variant{}}"#), .variant(["v": .variant()]))
        
    }
    
    func testRecordType() throws {
        XCTAssertEqual(try parser.parseType("record {}"), .record())
        XCTAssertEqual(try parser.parseType(#"record { first_name : text; text : text }"#), .record(["first_name": .text, "text": .text]))
        XCTAssertEqual(try parser.parseType(#"record { "name with spaces" : nat; "unicode, too: ☃" : bool }"#), .record(["name with spaces": .natural, "unicode, too: ☃": .bool]))
        XCTAssertEqual(try parser.parseType(#"record { text; text; opt bool }"#), .record(["0": .text, "1": .text, "2": .option(.bool)]))
        XCTAssertEqual(try parser.parseType(#"record{record{opt bool};"key":text;}"#), .record(["0": .record(["0": .option(.bool)]), "key": .text]))
    }
    
    func testFunctionType() throws {
        XCTAssertEqual(try parser.parseType("func () -> ()"), .function())
        XCTAssertEqual(try parser.parseType("func () -> () oneway"), .function(oneWay: true))
        XCTAssertEqual(try parser.parseType("func (text, opt bool) -> (text)"), .function([.text, .option(.bool)], [.text]))
        XCTAssertEqual(try parser.parseType("func () -> (int) query"), .function([], [.integer], query: true))
        XCTAssertEqual(try parser.parseType("func (func (int) -> ()) -> ()"), .function([.function([.integer], [])], []))
        
        let named = try parser.parseType("func (dividend : nat, divisor : nat) -> (div : nat, mod : nat);")
        XCTAssertEqual(named, .function([.natural, .natural], [.natural, .natural]))
        guard case .function(let signature) = named else {
            XCTFail()
            return
        }
        XCTAssertEqual(signature.arguments[0].name, "dividend")
        XCTAssertEqual(signature.arguments[1].name, "divisor")
        XCTAssertEqual(signature.results[0].name, "div")
        XCTAssertEqual(signature.results[1].name, "mod")
    }
}
//  .function([("a", .text)])

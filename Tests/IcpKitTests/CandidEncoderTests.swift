//
//  CandidEncoderTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 18.07.24.
//

import XCTest
import BigInt
import IcpKit

final class CandidEncoderTests: XCTestCase {
    func testSingleValueEncoding() throws {
        let testVectors: [(any Encodable, CandidValue)] = [
            (UInt8(0), .natural8(0)),
            (UInt16(1), .natural16(1)),
            (UInt32(2), .natural32(2)),
            (UInt64(3), .natural64(3)),
            (UInt(4), .natural64(4)),
            (Int8(0), .integer8(0)),
            (Int16(-1), .integer16(-1)),
            (Int32(-2), .integer32(-2)),
            (Int64(-3), .integer64(-3)),
            (Int(-4), .integer64(-4)),
            (true, .bool(true)),
            (false, .bool(false)),
            ("text", .text("text")),
            (Float(1.5), .float32(1.5)),
            (Double(1.5), .float64(1.5)),
            (BigUInt(5), .natural(5)),
            (BigInt(-5), .integer(-5)),
            (Data([]), .blob(Data())),
            (Data([1,2,3]), .blob(Data([1,2,3]))),
            
            (Optional(8), .option(.integer64(8))),
            (Bool?.none, .option(.bool)),
            (String?.none, .option(.text)),
            (Data?.none, .option(.blob)),
            (UInt8?.none, .option(.natural8)),
            (UInt16?.none, .option(.natural16)),
            (UInt32?.none, .option(.natural32)),
            (UInt64?.none, .option(.natural64)),
            (UInt?.none, .option(.natural64)),
            (BigUInt?.none, .option(.natural)),
            (Int8?.none, .option(.integer8)),
            (Int16?.none, .option(.integer16)),
            (Int32?.none, .option(.integer32)),
            (Int64?.none, .option(.integer64)),
            (Int?.none, .option(.integer64)),
            (BigInt?.none, .option(.integer)),
            (Float?.none, .option(.float32)),
            (Double?.none, .option(.float64)),
            (Optional(Optional(8)), .option(.option(.integer64(8)))),
            (Optional(Int?.none), .option(CandidValue.option(.integer64))),
            
            ([String](), .vector(.text)),
            ([UInt8]([8, 2]), try! .vector([.natural8(8), .natural8(2)])),
            ([UInt8?]([8, nil, 9]), try! .vector([.option(.natural8(8)), .option(.natural8), .option(.natural8(9))])),
            
            (["a":0], .record(["a": .integer64(0)])),
            (["a":0, "b": UInt8(8)], .record(["a": .natural8(0), "b": .natural8(8)])),
            (TestRecord(a: 1, b: 2), .record(["a": .natural8(1), "b": .integer64(2)])),
            //(TestRecursiveRecord(a: []), .record(["a": .vector(.record([]))])),
            
            (TestEnum.a, try! .variant(["a": .null], ("a", .null))),
            (TestEnum.b(2), try! .variant([ "b": .natural8], ("b", .natural8(2)))),
            (TestEnum.c(.a), try! .variant([ "c": .variant(["a":.null])], ("c", .variant(["a": .null], ("a", .null))))),
            
            (CandidFunction(signature: .init([CandidType](), []), method: nil), .function(CandidFunction(signature: .init([CandidType](), []), method: nil))),
            (try! CandidPrincipal("aaaaa-aa"), try! .principal("aaaaa-aa")),
            (CandidService(principal: nil, signature: .init([])), .service(CandidService(principal: nil, signature: .init([])))),
        ]
        
        for (input, expected) in testVectors {
            let encoded = try CandidEncoder().encode(input)
            XCTAssertEqual(encoded, expected)
        }
    }
}

private struct TestRecord: Encodable {
    let a: UInt8
    let b: Int
}

private struct TestRecursiveRecord: Encodable {
    let a: [TestRecursiveRecord]
}

private indirect enum TestEnum: Encodable {
    case a
    case b(UInt8)
    case c(TestEnum)
}

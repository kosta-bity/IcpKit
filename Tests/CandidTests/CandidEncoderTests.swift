//
//  CandidEncoderTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 18.07.24.
//

import XCTest
import BigInt
import Candid

final class CandidEncoderTests: XCTestCase {
    func testEncoding() throws {
        for (input, expected) in encodingTestVectors {
            let encoded = try CandidEncoder().encode(input)
            XCTAssertEqual(encoded, expected, String(describing: input))
            //XCTAssertTrue(encoded.candidType.isSubType(of: expected.candidType), "encoded \(encoded) is not a subtype of expected \(expected)")
        }
    }
    
    func testDecoding() throws {
        for (expected, input, type) in decodingTestVectors {
            do {
                let decoded = try CandidDecoder().decode(type, from: input)
                XCTAssertEqual(String(describing: decoded), String(describing: expected), "\(input) decoded to \(decoded) but was expecting \(expected)")
            } catch (let error) {
                XCTFail("\(input) failed to decode to \(expected). Error: \(error)")
            }
        }
        for (input, failingType, reason) in failingDecodingTestVectors {
            XCTAssertThrowsError(try CandidDecoder().decode(failingType, from: input), reason)
        }
    }
}

private let decodingTestVectors: [(any Codable, CandidValue, any Decodable.Type)] = [
    (true, .bool(true), Bool.self),
    (false, .bool(false), Bool.self),
    ("text", .text("text"), String.self),
    (UInt8(1), .natural8(1), UInt8.self),
    (UInt16(2), .natural16(2), UInt16.self),
    (UInt32(3), .natural32(3), UInt32.self),
    (UInt64(4), .natural64(4), UInt64.self),
    (UInt(5), .natural64(5), UInt.self),
    (BigUInt(6), .natural(6), BigUInt.self),
    (Int8(-1), .integer8(-1), Int8.self),
    (Int16(-2), .integer16(-2), Int16.self),
    (Int32(-3), .integer32(-3), Int32.self),
    (Int64(-4), .integer64(-4), Int64.self),
    (Int(-5), .integer64(-5), Int.self),
    (BigInt(-6), .integer(-6), BigInt.self),
    (Float(1.5), .float32(1.5), Float.self),
    (Double(1.5), .float64(1.5), Double.self),
    
    (Bool?.none, .option(.bool), Bool?.self),
    (BigInt?.none, .option(.integer), BigInt?.self),
    (Bool?(true), .option(.bool(true)), Bool?.self),
    (Bool??(true), .option(.option(.bool(true))), Bool??.self),
    (Bool??.none, .option(CandidType.option(.bool)), Bool??.self),
    (Optional(Bool?.none), .option(CandidValue.option(.bool)), Bool??.self),
    
    ([Int](), .vector(.integer), [Int].self),
    ([0,1], try! .vector([.integer64(0), .integer64(1)]), [Int].self),
    ([0,nil,2], try! .vector([.option(.integer64(0)), .option(.integer64), .option(.integer64(2))]), [Int?].self),
    ([[0,nil], []], try! .vector([.vector([.option(.integer64(0)), .option(.integer64)]), .vector(.option(.integer64))]), [[Int?]].self),
    
    (TestRecord(a: 1, b: 2), .record(["a": .natural8(1), "b": .integer64(2)]), TestRecord.self),
    (TestRecord2(a: [1, nil]), .record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])]), TestRecord2.self),
    (TestRecord3(record: TestRecord(a: 1, b: 2), records2: [TestRecord2(a: [1, nil])]), .record([
        "record":  .record(["a": .natural8(1), "b": .integer64(2)]),
        "records2": try! .vector([.record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])])]),
    ]), TestRecord3.self),
    (TestUnnamedRecord(anyName: "text", _1: 2), .record([.text("text"), .natural8(2)]), TestUnnamedRecord.self),
    (TestRecursiveRecord(a: []), .record(["a": .vector(.record())]), TestRecursiveRecord.self),
    (TestRecursiveRecord(a: [TestRecursiveRecord(a: [])]), .record(["a": try! .vector([.record(["a": .vector(.record())])])]), TestRecursiveRecord.self),
    
    (TestEnum.a, try! .variant(["a": .null], ("a", .null)), TestEnum.self),
    (TestEnum.b(2), try! .variant([ "b": .natural8], ("b", .natural8(2))), TestEnum.self),
    (TestEnum.c(.a), try! .variant([ "c": .variant(["a":.null])], ("c", .variant(["a": .null], ("a", .null)))), TestEnum.self),
    (TestEnum.d([1,2]), try! .variant([ "d": .vector(.natural8)], ("d", .vector([.natural8(1), .natural8(2)]))), TestEnum.self),
    (TestEnum.e(a: 1, b: 2), try! .variant(["e": .record(["a": .natural8, "b": .natural16])], ("e", .record(["a":.natural8(1), "b": .natural16(2)]))), TestEnum.self),
    (TestEnum.f(1, 2), try! .variant(["f": .record([0: .natural8, 1: .natural16])], ("f", .record([0:.natural8(1), 1:.natural16(2)]))), TestEnum.self),
    (TestEnum.g(SingleValueRecord(value: 2)), try! .variant(["g": .record(["value": .integer8])], ("g", .record(["value": .integer8(2)]))), TestEnum.self),
    
]

private let failingDecodingTestVectors: [(CandidValue, any Decodable.Type, String)] = [
    (.integer8(-1), UInt8.self, "negative number can not convert to unsigned"),
    //(.option(CandidType.option(.bool)), Bool?.self, "opt opt bool not compatible with opt bool"),
    //(.option(.natural), Bool?.self, "BigUInt?.none can not convert to Bool?.none")
    //(.vector(.integer), [Bool].self, "incompatible vector types")
]

private let encodingTestVectors: [(any Encodable, CandidValue)] = [
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
    // The following fails because we can not identify the wrapped type of wrapped optionals with nil value...
    //(Int??.none, .option(CandidType.option(.integer64))),   // returns opt opt empty
    //(TestRecord?.none, .option(.record(["a": .natural8, "b":.integer64]))), // returns opt empty
    
    ([String](), .vector(.text)),
    ([UInt8]([8, 2]), try! .vector([.natural8(8), .natural8(2)])),
    ([UInt8?]([8, nil, 9]), try! .vector([.option(.natural8(8)), .option(.natural8), .option(.natural8(9))])),
    
    (["a":0], .record(["a": .integer64(0)])),
    (["a":0, "b": UInt8(8)], .record(["a": .natural8(0), "b": .natural8(8)])),
    (TestRecord(a: 1, b: 2), .record(["a": .natural8(1), "b": .integer64(2)])),
    (TestRecord2(a: [1, nil]), .record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])])),
    (TestRecord3(record: TestRecord(a: 1, b: 2), records2: [TestRecord2(a: [1, nil])]), .record([
        "record":  .record(["a": .natural8(1), "b": .integer64(2)]),
        "records2": try! .vector([.record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])])]),
    ])),
    (TestUnnamedRecord(anyName: "text", _1: 2), .record([.text("text"), .natural8(2)])),
    // this fails because we don't correctly identify the recursive type.
    //(TestRecursiveRecord(a: []), .record(["a": .vector(.record())])),
    
    (TestEnum.a, try! .variant(["a": .null], ("a", .null))),
    (TestEnum.b(2), try! .variant([ "b": .natural8], ("b", .natural8(2)))),
    (TestEnum.c(.a), try! .variant([ "c": .variant(["a":.null])], ("c", .variant(["a": .null], ("a", .null))))),
    (TestEnum.d([1,2]), try! .variant([ "d": .vector(.natural8)], ("d", .vector([.natural8(1), .natural8(2)])))),
    (TestEnum.e(a: 1, b: 2), try! .variant(["e": .record(["a": .natural8, "b": .natural16])], ("e", .record(["a":.natural8(1), "b": .natural16(2)])))),
    (TestEnum.f(1, 2), try! .variant(["f": .record([0: .natural8, 1: .natural16])], ("f", .record([0:.natural8(1), 1:.natural16(2)])))),
    (TestEnum.g(SingleValueRecord(value: 2)), try! .variant(["g": .record(["value": .integer8])], ("g", .record(["value": .integer8(2)])))),
    
    (CandidFunction(signature: .init([CandidType](), []), method: nil), .function(CandidFunction(signature: .init([CandidType](), []), method: nil))),
    (try! CandidPrincipal("aaaaa-aa"), try! .principal("aaaaa-aa")),
    (CandidService(principal: nil, signature: .init([])), .service(CandidService(principal: nil, signature: .init([])))),
]

private struct TestRecord: Codable {
    let a: UInt8
    let b: Int
}

private struct TestRecord2: Codable {
    let a: [UInt8?]
}

private struct TestRecord3: Codable {
    let record: TestRecord
    let records2: [TestRecord2]
}

struct TestUnnamedRecord: Codable {
    let anyName: String
    let _1: UInt8
    
    enum CodingKeys: Int, CodingKey {
        case anyName = 0
        case _1 = 1
    }
}

private struct TestRecursiveRecord: Codable {
    let a: [TestRecursiveRecord]
}

private indirect enum TestEnum: Codable {
    case a
    case b(UInt8)
    case c(TestEnum)
    case d([UInt8])
    case e(a: UInt8, b: UInt16)
    case f(UInt8, UInt16)
    case g(SingleValueRecord)
}

struct SingleValueRecord: Codable {
    let value: Int8
}

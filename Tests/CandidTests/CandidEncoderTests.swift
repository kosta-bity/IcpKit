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
        let vectors = commonTestVectors.map { ($0.0, $0.1) } + encodingTestVectors
        for (input, expected) in vectors {
            let encoded = try CandidEncoder().encode(input)
            XCTAssertEqual(encoded, expected, String(describing: input))
        }
    }
    
    func testDecoding() throws {
        let vectors = commonTestVectors + decodingTestVectors
        for (expected, input, type) in vectors {
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

private let commonTestVectors: [(any Codable, CandidValue, any Decodable.Type)] = [
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
    (Data([]), .blob(Data()), Data.self),
    (Data([1,2,3,4]), .blob(Data([1,2,3,4])), Data.self),
    (Data?.some(Data([1])), .option(.blob(Data([1]))), Data?.self),
    
    (Optional(8), .option(.integer64(8)), Int?.self),
    (Bool?.none, .option(.bool), Bool?.self),
    (String?.none, .option(.text), String?.self),
    (Bool?(true), .option(.bool(true)), Bool?.self),
    (Bool??(true), .option(.option(.bool(true))), Bool??.self),
    (Optional(Bool?.none), .option(CandidValue.option(.bool)), Bool??.self),
    (Data?.none, .option(.blob), Data?.self),
    (Data?.some(Data([1,2])), .option(.blob(Data([1,2]))), Data?.self),
    (UInt8?.none, .option(.natural8), UInt8?.self),
    (UInt16?.none, .option(.natural16), UInt16?.self),
    (UInt32?.none, .option(.natural32), UInt32?.self),
    (UInt64?.none, .option(.natural64), UInt64?.self),
    (UInt?.none, .option(.natural64), UInt?.self),
    (BigUInt?.none, .option(.natural), BigUInt?.self),
    (Int8?.none, .option(.integer8), Int8?.self),
    (Int16?.none, .option(.integer16), Int16?.self),
    (Int32?.none, .option(.integer32), Int32?.self),
    (Int64?.none, .option(.integer64), Int64?.self),
    (Int?.none, .option(.integer64), Int?.self),
    (BigInt?.none, .option(.integer), BigInt?.self),
    (Float?.none, .option(.float32), Float?.self),
    (Double?.none, .option(.float64), Double?.self),
    (Optional(Optional(8)), .option(.option(.integer64(8))), Int??.self),
    (Optional(Int?.none), .option(CandidValue.option(.integer64)), Int??.self),
    (Int??.none, .option(CandidType.option(.integer64)), Int??.self),
    (Bool??.none, .option(CandidType.option(.bool)), Bool??.self),
    
    ([String](), .vector(.text), [String].self),
    ([Int](), .vector(.integer64), [Int].self),
    ([0,1], try! .vector([.integer64(0), .integer64(1)]), [Int].self),
    ([0,nil,2], try! .vector([.option(.integer64(0)), .option(.integer64), .option(.integer64(2))]), [Int?].self),
    ([[0,nil], []], try! .vector([.vector([.option(.integer64(0)), .option(.integer64)]), .vector(.option(.integer64))]), [[Int?]].self),
    
    (["a": 0], .record(["a": .integer64(0)]), [String: Int].self),
    // this test works but the produced dictionary has random order
    //(["b": UInt8(8), "a": 0], .record(["a": .natural8(0), "b": .natural8(8)]), [String: UInt8].self),
    
    (TestRecord(a: 1, b: 2), .record(["a": .natural8(1), "b": .integer64(2)]), TestRecord.self),
    (TestRecord2(a: [1, nil]), .record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])]), TestRecord2.self),
    (TestRecord3(record: TestRecord(a: 1, b: 2), records2: [TestRecord2(a: [1, nil])]), .record([
        "record":  .record(["a": .natural8(1), "b": .integer64(2)]),
        "records2": try! .vector([.record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])])]),
    ]), TestRecord3.self),
    (TestUnnamedRecord(anyName: "text", _1: 2), .record([.text("text"), .option(.natural8(2))]), TestUnnamedRecord.self),
    (TestDataRecord2(data: Data([1])), .record(["data": .option(.blob(Data([1])))]), TestDataRecord2.self),
    (TestDataRecord3(data: Data([1])), .record(["data": .option(.option(.blob(Data([1]))))]), TestDataRecord3.self),
    (TestDataRecord(vector: [.init(data: Data([1]))]), .record(["vector": try! .vector([.record(["data": .option(.blob(Data([1])))])])]), TestDataRecord.self),
    (TestRecord(a: 1, b: 2), .record([97: .natural8(1), 98: .integer64(2)]), TestRecord.self),
    (TestDataRecord2(data: nil), .record(["data": .option(.blob)]), TestDataRecord2.self),
    (TestRecord?.none, .option(CandidType.empty), TestRecord?.self),    // can not detect type of nil structs
    (PassThroughCandidValue(candid: .option(CandidType.reserved)), .record(["candid": .option(CandidType.reserved)]), PassThroughCandidValue.self),
    
    (TestEnum.a, .variant(.init("a", .null)), TestEnum.self),
    (TestEnum.b(2), .variant(.init("b", .option(.natural8(2)))), TestEnum.self),
    (TestEnum.c(.a), .variant(.init("c", .variant(.init("a")))), TestEnum.self),
    (TestEnum.d([1,2]), .variant(.init("d", try! .vector([.natural8(1), .natural8(2)]))), TestEnum.self),
    (TestEnum.e(a: 1, b: 2), .variant(.init("e", .record(["a":.option(.natural8(1)), "b": .natural16(2)]))), TestEnum.self),
    (TestEnum.e(a: 1, b: 2), .variant(.init(101, .record([97:.option(.natural8(1)), 98: .natural16(2)]))), TestEnum.self),
    (TestEnum.f(1, 2), .variant(.init("f", .record([0: .option(.natural8(1)), 1: .natural16(2)]))), TestEnum.self),
    (TestEnum.g(SingleValueRecord(value: 2)), .variant(.init("g", .record(["value": .integer8(2)]))), TestEnum.self),
    (TestEnum.h(a: 2), .variant(.init("h", .record(["a": .option(.natural8(2))]))), TestEnum.self),
    
    (CandidPrincipal("aaaaa-aa"), try! .principal("aaaaa-aa"), CandidPrincipal.self),
    
    (try! TestFunction("aaaaa-aa", "foo"), .function(CandidFunction(signature: .init([CandidType](), []), principal: CandidPrincipal("aaaaa-aa"), methodName: "foo")), TestFunction.self),
    (try! TestService("aaaaa-aa"), try! .service("aaaaa-aa"), TestService.self),
]

// these cases only work when decoding from a candidvalue
private let decodingTestVectors: [(any Codable, CandidValue, any Decodable.Type)] = [
    (Bool?.none, .null, Bool?.self),
    (Bool?.none, .empty, Bool?.self),
    (Bool?.none, .reserved, Bool?.self),
    (Bool?.none, .option(CandidType.empty), Bool?.self),
    (Bool?.none, .option(CandidValue.empty), Bool?.self),
    (Bool?.none, .option(CandidValue.null), Bool?.self),
    (Bool?.none, .option(CandidType.null), Bool?.self),
    (Bool?.none, .option(CandidValue.reserved), Bool?.self),
    (Bool?.none, .option(CandidType.reserved), Bool?.self),
    (Data([1,2]), try! .vector([.natural8(1), .natural8(2)]), Data.self),       // vec nat8 to Data conversion
    (TestRecursiveRecord(a: []), .record(["a": .vector(.record())]), TestRecursiveRecord.self),
    (TestRecord?.none, .option(.record(["a": .natural8, "b":.integer64])), TestRecord?.self),   // nil records can detect type correct only on decoding
    (TestDataRecord2(data: nil), .record(), TestDataRecord2.self),  // missing optional values
    (TestEnum.b(nil), .variant(CandidKeyedValue("b")), TestEnum.self),  // missing optional values
    (TestEnum.e(a: nil, b: 1), .variant(CandidKeyedValue("e", .record(["b": .natural16(1)]))), TestEnum.self),  // missing optional values
]

private let failingDecodingTestVectors: [(CandidValue, any Decodable.Type, String)] = [
    (.integer8(-1), UInt8.self, "negative number can not convert to unsigned"),
]

// tese cases only work when encoding to a candidvalue
private let encodingTestVectors: [(any Encodable, CandidValue)] = [
    //(TestRecord?.none, .option(.record(["a": .natural8, "b":.integer64]))), // returns opt empty
    (CandidFunction(signature: .init([CandidType](), []), method: nil), .function(CandidFunction(signature: .init([CandidType](), []), method: nil))),
    (CandidService(principal: nil, signature: .init([])), .service(CandidService(principal: nil, signature: .init([])))),
    (["b": UInt8(8), "a": 0], .record(["a": .natural8(0), "b": .natural8(8)])),
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

private struct TestUnnamedRecord: Codable {
    let anyName: String
    let _1: UInt8?
    
    enum CodingKeys: Int, CodingKey {
        case anyName
        case _1
    }
}

private struct TestRecursiveRecord: Codable {
    let a: [TestRecursiveRecord]
}

private struct TestDataRecord: Codable {
    let vector: [TestDataRecord2]
}

private struct TestDataRecord2: Codable {
    let data: Data?
}

private struct TestDataRecord3: Codable {
    let data: Data??
}

private indirect enum TestEnum: Codable {
    case a
    case b(UInt8?)
    case c(TestEnum)
    case d([UInt8])
    case e(a: UInt8?, b: UInt16)
    case f(UInt8?, UInt16)
    case g(SingleValueRecord)
    case h(a: UInt8?)
    
    enum CodingKeys: String, CandidCodingKey {
        case a
        case b
        case c
        case d
        case e
        case f
        case g
        case h
    }
    
    enum ECodingKeys: String, CandidCodingKey {
        case a
        case b
    }
}

struct SingleValueRecord: Codable {
    let value: Int8
}

struct PassThroughCandidValue: Codable {
    let candid: CandidValue
}

struct TestFunction: CandidFunctionProtocol {
    let canister: Candid.CandidPrincipal
    let methodName: String
    let isQuery: Bool = true
    
    init(_ canister: CandidPrincipal, _ method: String) {
        self.canister = canister
        self.methodName = method
    }
}

struct TestService: CandidServiceProtocol {
    let principal: CandidPrincipal
    
    init(_ principal: CandidPrincipal) {
        self.principal = principal
    }
}

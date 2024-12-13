//
//  ICPCertificateTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 04.05.23.
//

import XCTest
@testable import IcpKit

final class ICPCertificateTests: XCTestCase {

    func testCborParsing() throws {
// from https://internetcomputer.org/docs/current/references/ic-interface-spec/#example
//       ─┬─┬╴"a" ─┬─┬╴"x" ─╴"hello"
//        │ │      │ └╴Empty
//        │ │      └╴  "y" ─╴"world"
//        │ └╴"b" ──╴"good"
//        └─┬╴"c" ──╴Empty
//          └╴"d" ──╴"morning"
        let cborData = Data.fromHex( "8301830183024161830183018302417882034568656c6c6f810083024179820345776f726c6483024162820344676f6f648301830241638100830241648203476d6f726e696e67")!
        let cbor = try ICPCryptography.CBOR.deserialiseCbor(from: cborData)
        let certificate = try ICPStateCertificate.HashTreeNode.buildTree(from: cbor)
        
        XCTAssertEqual(certificate,
            .fork(
                left: .fork(
                    left: .labeled("a", .fork(
                        left: .fork(
                            left: .labeled("x", .leaf("hello".data)),
                            right: .empty),
                        right: .labeled("y", .leaf("world".data)))),
                    right: .labeled("b", .leaf("good".data))),
                right: .fork(
                    left: .labeled("c", .empty),
                    right: .labeled("d", .leaf("morning".data)))
            )
        )
        
        XCTAssertEqual(certificate.getNode(for: "/a/x"), .leaf("hello".data))
        XCTAssertEqual(certificate.getNode(for: "/a/y"), .leaf("world".data))
        XCTAssertEqual(certificate.getNode(for: "/b"), .leaf("good".data))
        XCTAssertEqual(certificate.getNode(for: "/c"), .empty)
        XCTAssertEqual(certificate.getNode(for: "/d"), .leaf("morning".data))
        XCTAssertNil(certificate.getNode(for: "/x"))
        XCTAssertNil(certificate.getNode(for: "/a/c"))
        XCTAssertNil(certificate.getNode(for: "/a/x/x"))
        XCTAssertEqual(certificate.getNode(for: "/a"), .fork(
            left: .fork(
                left: .labeled("x", .leaf("hello".data)),
                right: .empty),
            right: .labeled("y", .leaf("world".data))))
        
        XCTAssertEqual(certificate.getValue(for: "/a/x"), "hello".data)
        XCTAssertEqual(certificate.getValue(for: "/a/y"), "world".data)
        XCTAssertEqual(certificate.getValue(for: "/b"), "good".data)
        XCTAssertEqual(certificate.getValue(for: "/d"), "morning".data)
        XCTAssertEqual(certificate.getValue(for: "/unknown_path"), nil)
        XCTAssertEqual(certificate.getValue(for: "/c"), nil)
        XCTAssertEqual(certificate.getValue(for: "/a"), nil)
        
        XCTAssertEqual(certificate.hash().hex, "eb5c5b2195e62d996b84c9bcc8259d19a83786a2f59e0878cec84c811f669aa0")
    }
    
    func testCborPrunedParsing() throws {
// from https://internetcomputer.org/docs/current/references/ic-interface-spec/#example
// This tree represents the same state tree as in previous state,
// some of the branches have been pruned but the hash of the tree is the same for both trees
//       ─┬─┬╴"a" ─┬─ 1B4FEFF9BEF8131788B0C9DC6DBAD6E81E524249C879E9F10F71CE3749F5A638
//        │ │      └╴ "y" ─╴"world"
//        │ └╴"b" ──╴7B32AC0C6BA8CE35AC82C255FC7906F7FC130DAB2A090F80FE12F9C2CAE83BA6
//        └─┬╴EC8324B8A1F1AC16BD2E806EDBA78006479C9877FED4EB464A25485465AF601D
//          └╴"d" ──╴"morning"
        let cborData = Data.fromHex( "83018301830241618301820458201b4feff9bef8131788b0c9dc6dbad6e81e524249c879e9f10f71ce3749f5a63883024179820345776f726c6483024162820458207b32ac0c6ba8ce35ac82c255fc7906f7fc130dab2a090f80fe12f9c2cae83ba6830182045820ec8324b8a1f1ac16bd2e806edba78006479c9877fed4eb464a25485465af601d830241648203476d6f726e696e67")!
        let cbor = try ICPCryptography.CBOR.deserialiseCbor(from: cborData)
        let certificate = try ICPStateCertificate.HashTreeNode.buildTree(from: cbor)
        
        XCTAssertEqual(certificate, .fork(
            left: .fork(
                left: .labeled("a", .fork(
                    left: .pruned(.fromHex("1B4FEFF9BEF8131788B0C9DC6DBAD6E81E524249C879E9F10F71CE3749F5A638")!),
                    right: .labeled("y", .leaf("world".data))
                )),
                right: .labeled("b", .pruned(.fromHex("7B32AC0C6BA8CE35AC82C255FC7906F7FC130DAB2A090F80FE12F9C2CAE83BA6")!))
            ),
            right: .fork(
                left: .pruned(.fromHex("EC8324B8A1F1AC16BD2E806EDBA78006479C9877FED4EB464A25485465AF601D")!),
                right: .labeled("d", .leaf("morning".data)))))
        
        XCTAssertEqual(certificate.getValue(for: "/a/x"), nil)
        XCTAssertEqual(certificate.getValue(for: "/a/y"), "world".data)
        XCTAssertEqual(certificate.getValue(for: "/b"), nil)
        XCTAssertEqual(certificate.getValue(for: "/d"), "morning".data)
        XCTAssertEqual(certificate.getValue(for: "/unknown_path"), nil)
        XCTAssertEqual(certificate.getValue(for: "/c"), nil)
        XCTAssertEqual(certificate.getValue(for: "/a"), nil)
        
        XCTAssertEqual(certificate.hash().hex, "eb5c5b2195e62d996b84c9bcc8259d19a83786a2f59e0878cec84c811f669aa0")
    }
}

extension String {
    var data: Data {
        Data(utf8)
    }
}

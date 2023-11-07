//
//  Leb128Tests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 01.05.23.
//

import XCTest
import BigInt
@testable import IcpKit

final class Leb128Tests: XCTestCase {

    // test vectors generated using python leb128 https://pypi.org/project/leb128/
    func testLeb128EncodeUnsigned() {
        let testVectors: [(BigUInt, [UInt8])] = [
            (0,[0x00]),
            (127,[0x7f]),
            (128,[0x80, 0x01]),
            (300, [0xac, 0x02]),
            (255, [0xff, 0x01]),
            (624485, [0xe5, 0x8e, 0x26]),
            (18446744073709551615, [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01]),
        ]
        for (value, expected) in testVectors {
            XCTAssertEqual(ICPCryptography.Leb128.encodeUnsigned(value), Data(expected))
        }
    }
    
    // test vectors generated using python leb128 https://pypi.org/project/leb128/
    func testLeb128EncodeSigned() {
        let testVectors: [(BigInt, [UInt8])] = [
            (0,[0x00]),
            (63,[0x3f]),
            (64,[0xc0, 0x00]),
            (-63,[0x41]),
            (-64,[0x40]),
            (-65,[0xbf, 0x7f]),
            (-128,[0x80, 0x7f]),
            (-129,[0xff, 0x7e]),
            (97, [0xe1, 0x00]),
            (127,[0xff, 0x00]),
            (624485, [0xe5, 0x8e, 0x26]),
            (-123456, [0xc0, 0xbb, 0x78]),
            (-999999999, [0x81, 0xec, 0x94, 0xa3, 0x7c]),
        ]
        for (value, expected) in testVectors {
            XCTAssertEqual(ICPCryptography.Leb128.encodeSigned(value), Data(expected))
        }
    }
    
    func testLeb128DecodeUnsigned() throws {
        let testVectors: [(BigUInt, [UInt8])] = [
            (0,[0x00]),
            (127,[0x7f]),
            (128,[0x80, 0x01]),
            (300, [0xac, 0x02]),
            (255, [0xff, 0x01]),
            (624485, [0xe5, 0x8e, 0x26]),
            (18446744073709551615, [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01]),
        ]
        for (expected, inputBytes) in testVectors {
            let data = Data(inputBytes)
            let stream = ByteInputStream(data)
            XCTAssertEqual(try ICPCryptography.Leb128.decodeUnsigned(stream), expected)
            XCTAssertFalse(stream.hasBytesAvailable)
        }
    }
    
    func testLeb128DecodeSigned() {
        let testVectors: [(BigInt, [UInt8])] = [
            (0,[0x00]),
            (63,[0x3f]),
            (64,[0xc0, 0x00]),
            (-63,[0x41]),
            (-64,[0x40]),
            (-65,[0xbf, 0x7f]),
            (-128,[0x80, 0x7f]),
            (-129,[0xff, 0x7e]),
            (97, [0xe1, 0x00]),
            (127,[0xff, 0x00]),
            (624485, [0xe5, 0x8e, 0x26]),
            (-123456, [0xc0, 0xbb, 0x78]),
            (-999999999, [0x81, 0xec, 0x94, 0xa3, 0x7c]),
        ]
        for (expected, inputBytes) in testVectors {
            let data = Data(inputBytes)
            let stream = ByteInputStream(data)
            XCTAssertEqual(try ICPCryptography.Leb128.decodeSigned(stream), expected)
            XCTAssertFalse(stream.hasBytesAvailable)
        }
    }
    
    // TODO: Remove this when Leb encodeSigned works with BigInt
    func testLeb128EncodeSignedBigInt() {
        for i in 0...255 {
            let int = ICPCryptography.Leb128.encodeSigned(-i)
            let bigInt = ICPCryptography.Leb128.encodeSigned(BigInt(-i))
            XCTAssertEqual(int, bigInt)
            if int != bigInt {
                print("MISMATCH \(i) --> int: \(int.hex) | bigInt: \(bigInt.hex)")
            }
        }
    }

}

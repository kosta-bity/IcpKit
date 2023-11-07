//
//  CandidSerialisationTestVectors.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 01.05.23.
//

import Foundation
@testable import IcpKit

enum CandidSerialisationTestVectors {
    static let singleValueTestVectors: [(CandidValue, [UInt8])] = [
        (.null, [0x00, 0x01, 0x7F]),
        (.bool(false), [0x00, 0x01, 0x7E, 0x00]),
        (.bool(true), [0x00, 0x01, 0x7E, 0x01]),
        (.natural(0), [0x00, 0x01, 0x7D, 0x00]),
        (.natural(1), [0x00, 0x01, 0x7D, 0x01]),
        (.natural(300), [0x00, 0x01, 0x7D, 0xAC, 0x02]),
        (.integer(-129), [0x00, 0x01, 0x7C, 0xFF, 0x7E]),
        (.natural8(5), [0x00, 0x01, 0x7B, 0x05]),
        (.natural16(5), [0x00, 0x01, 0x7A, 0x05, 0x00]),
        (.natural32(5), [0x00, 0x01, 0x79, 0x05, 0x00, 0x00, 0x00]),
        (.natural64(5), [0x00, 0x01, 0x78, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
        (.integer8(-5), [0x00, 0x01, 0x77, 0xfb]),
        (.integer16(-5), [0x00, 0x01, 0x76, 0xfB, 0xff]),
        (.integer32(-5), [0x00, 0x01, 0x75, 0xfB, 0xff, 0xff, 0xff]),
        (.integer64(-5), [0x00, 0x01, 0x74, 0xfB, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]),
        (.float32(-0.5), [0x00, 0x01, 0x73, 0x00, 0x00, 0x00, 0xbf]),
        (.float32(-0.768), [0x00, 0x01, 0x73, 0xa6, 0x9b, 0x44, 0xbf]),
        (.float64(-0.768), [0x00, 0x01, 0x72, 0xFA, 0x7E, 0x6A, 0xBC, 0x74, 0x93, 0xE8, 0xBF]),
        (.reserved, [0x00, 0x01, 0x70]),
        (.empty, [0x00, 0x01, 0x6F]),
        (.text("a"), [0x00, 0x01, 0x71, 0x01, 0x61]),
        (.text("%±§"), [0x00, 0x01, 0x71, 0x05, 0x25, 0xc2, 0xb1, 0xc2, 0xa7]),
        // 1 type in table, option, bool, 1 candidValue, value of type 0, null value
        (.option(.bool), [0x01, 0x6E, 0x7E, 0x01, 0x00, 0x00]),
        // 1 type in table, option, bool, 1 candidValue, value of type 0, non-null value, true
        (.option(.bool(true)), [0x01, 0x6E, 0x7E, 0x01, 0x00, 0x01, 0x01]),
        // 1 type in table, vector, bool, 1 candidValue, value of type 0, 0 elements
        (.vector(.bool), [0x01, 0x6D, 0x7E, 0x01, 0x00, 0x00]),
        // 1 type in table, vector, bool, 1 candidValue, value of type 0, 2 elements, true, false
        (.vector([.bool(true), .bool(false)]), [0x01, 0x6D, 0x7E, 0x01, 0x00, 0x02, 0x01, 0x00]),
        // 1 type in table, vector, nat8, 1 candidValue, value of type 0, 0 elements
        (.blob(Data()), [0x01, 0x6D, 0x7B, 0x01, 0x00, 0x00]),
        // 1 type in table, vector, nat8, 1 candidValue, value of type 0, 2 elements, 127, 128
        (.blob(Data([127, 128])), [0x01, 0x6D, 0x7B, 0x01, 0x00, 0x02, 0x7F, 0x80]),
        // 1 type in table, record, 0 rows, 1 candidValue, value of type 0,
        (.record([:]),[0x01, 0x6C, 0x00, 0x01, 0x00]),
        // 1 type in table, record, 1 row, leb(hash("a")), .empty, 1 candidValue, value of type 0,
        (.record(["a":.empty]),[0x01, 0x6C, 0x01, 97, 0x6F, 0x01, 0x00]),
        // 1 type in table, record, 2 rows, leb(hash("a")), .natural, leb(hash("b")), .natural8, 1 candidValue, value of type 0, 0x01, 0x02
        (.record(["a":.natural(1),"b":.natural8(2)]), [0x01, 0x6C, 0x02, 97, 0x7D, 98, 0x7B, 0x01, 0x00, 0x01, 0x02]),
        // 2 types in table, (0)vector, bool, (1)option, referencing type 0, 1 candidValue, value of type 1, option present, 2 values, true, false
        (.option(.vector([.bool(true), .bool(false)])), [0x02, 0x6D, 0x7E, 0x6E, 0x00, 0x01, 0x01, 0x01, 0x02, 0x01, 0x00]),
        // 3 types in table, (0)vector, nat8, (1) vector, ref 0, (2)option, ref 1, 1 candidValue, value of type 2, option present, 2 values, length 0, length 2, leb(127), leb(128)
        (.option(.vector([.blob(Data()), .blob(Data([127, 128]))])), [0x03, 0x6D, 0x7B, 0x6D, 0x00, 0x6E, 0x01, 0x01, 0x02, 0x01, 0x02, 0x00, 0x02, 0x7F, 0x80]),
        // 4 types in table, (0)vector, nat8, (1) vector, ref 0, (2) record, 2 keys, leb(hash("a")), ref 0, leb(hash("b")), ref 1, (3)option, ref 2, 1 candidValue, value of type 3, option present, length 1, 0x44, length 1, length 2, 0x45, 0x47
        (.option(.record([
            "a": .blob(Data([0x44])),
            "b": .vector([.blob(Data([0x45, 0x47]))] )
        ])), [4, 0x6D, 0x7B, 0x6D, 0, 0x6C, 2, 97, 0, 98, 1, 0x6E, 2, 0x01, 3, 1, 1, 0x44, 1, 2, 0x45, 0x47]),
        (.variant(try! CandidVariant(
            candidTypes: [
                ("a", .primitive(.bool)),
                ("b", .primitive(.natural8)),
                ("c", .container(.vector, .primitive(.natural8))),
            ],
            value: ("b", .natural8(15)))),
         // 2 types in table, (0) vector, nat8, (1) variant, 3 keys, leb(hash("a")), bool, leb(hash("b")), nat8, leb(hash("c")), type 0, 1 candidValue, type 1, row 1, 15
         [2, 0x6D, 0x7B, 0x6B, 3, 97, 0x7E, 98, 0x7B, 99, 0, 1, 1, 1, 0x0f]),
    ]
    
    static let multipleValuesTestVectors: [([CandidValue], [UInt8])] = [
        ([], [0x00, 0x00]),
        ([.natural8(0), .natural8(1), .natural8(2)], [0x00, 0x03, 0x7B, 0x7B, 0x7B, 0, 1, 2]),
        ([.natural8(0), .natural16(258), .natural8(2)], [0x00, 0x03, 0x7B, 0x7A, 0x7B, 0, 2, 1, 2]),
        ([
            .option(.record([
                "a": .blob(Data([0x44])),
                "b": .vector([.blob(Data([0x45, 0x47]))] )
            ])),
            .record([
                "a": .blob(Data([0x43])),
                "b": .vector([.blob(Data([0x40, 0x41]))] )
            ]),
        // 4 types in table, (0)vector, nat8, (1) vector, ref 0, (2) record, 2 keys, leb(hash("a")), ref 0, leb(hash("b")), ref 1, (3)option, ref 2, 2 candidValues, value of type 3, value of type 2, option present, length 1, 0x44, length 1, length 2, 0x45, 0x47,  length 1, 0x43, length 1, length 2, 0x40, 0x41
         ], [4, 0x6D, 0x7B, 0x6D, 0, 0x6C, 2, 97, 0, 98, 1, 0x6E, 2, 0x02, 3, 2, 1, 1, 0x44, 1, 2, 0x45, 0x47, 1, 0x43, 1, 2, 0x40, 0x41]),
    ]
}

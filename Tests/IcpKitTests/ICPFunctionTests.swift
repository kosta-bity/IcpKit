//
//  ICPFunctionTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 10.09.24.
//

import XCTest
import IcpKit
import Candid

final class ICPFunctionTests: XCTestCase {
    let coder = ICPFunctionArgsCoder()
    
    func testICPFunctionArgsCoder() throws {
        let testVectors: [(any CodableEquatable.Type, any CodableEquatable, [CandidValue])] = [
            (Bool.self, true, [.bool(true)]),
            (CandidTuple2<Bool, Int>.self, CandidTuple2(true, 1), [.record([.bool(true), .integer64(1)])]),
            (ICPFunctionArgs2<Bool, Int>.self, ICPFunctionArgs2(true, 1), [.bool(true), .integer64(1)]),
            (ICPFunctionArgs3<Bool, Int, Data>.self, ICPFunctionArgs3(true, 1, Data()), [.bool(true), .integer64(1), .blob(Data())]),
            (ICPFunctionArgs4<Bool, Int, Data, Bool?>.self, ICPFunctionArgs4(true, 1, Data(), Bool?.none), [.bool(true), .integer64(1), .blob(Data()), .option(.bool)]),
            (ICPFunctionArgs5<Bool, Int, Data, Bool?, Int?>.self, ICPFunctionArgs5(true, 1, Data(), Bool?.none, Int?.none), [.bool(true), .integer64(1), .blob(Data()), .option(.bool), .option(.integer64)]),
            (ICPFunctionArgs6<Bool, Int, Data, Bool?, Int?, ICPPrincipal>.self, ICPFunctionArgs6(true, 1, Data(), Bool?.none, Int?.none, ICPPrincipal("aaaaa-aa")), [.bool(true), .integer64(1), .blob(Data()), .option(.bool), .option(.integer64), try! .principal("aaaaa-aa")]),
            (ICPFunctionArgs7<Bool, Int, Data, Bool?, Int?, ICPPrincipal, String>.self, ICPFunctionArgs7(true, 1, Data(), Bool?.none, Int?.none, ICPPrincipal("aaaaa-aa"), "text"), [.bool(true), .integer64(1), .blob(Data()), .option(.bool), .option(.integer64), try! .principal("aaaaa-aa"), .text("text")]),
        ]
        
        for (type, value, candidValue) in testVectors {
            let encoded = try coder.encode(value)
            let decoded = try coder.decode(type, from: candidValue)
            XCTAssertEqual(encoded, candidValue)
            XCTAssertTrue(compare(type, decoded, value))
        }
    }
    
    private func compare<T: Equatable>(_ type: T.Type, _ a: Any, _ b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }
        return a == b
    }
}

private typealias CodableEquatable = Codable & Equatable

//
//  ICPTransactionHashTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 16.11.23.
//

import XCTest
@testable import IcpKit

final class ICPTransactionHashTests: XCTestCase {
    func testHash() throws {
        let transaction = ICPBlock.Transaction.init(
            memo: 1699434456,
            createdNanos: 1699434456596306831,
            operation: .transfer(
                from: Data.fromHex("e9344613c9615a83cf15748d9265c77b76244166678d4a0fd5df13186c64b9c4")!,
                to: Data.fromHex("b87f601d508c2fe1967d1eaceb4e81205e77e29dc46eb96df2028881ed4c9f8c")!,
                amount: 1_418_990_000,
                fee: 10_000
            )
        )
        let calculatedHash = try ICPCryptography.transactionHash(transaction).hex
        let expectedHash = "e609323577ef35afca168a5b45504549889f4086dba5ef4fae8d9dfb2e9666e0"
        XCTAssertEqual(calculatedHash, expectedHash)
    }
}

// https://cbor.nemo157.com/#type=hex&value=a300a102a4007840653933343436313363393631356138336366313537343864393236356337376237363234343136363637386434613066643564663133313836633634623963340178406238376636303164353038633266653139363764316561636562346538313230356537376532396463343665623936646632303238383831656434633966386302a1001a549411b003a100192710011a654b4fd802a1001b17959aa2607b5b8f
// https://dashboard.internetcomputer.org/transaction/e609323577ef35afca168a5b45504549889f4086dba5ef4fae8d9dfb2e9666e0

////
////  ICPIntegrationTests.swift
////  IntegrationTests
////
////  Created by Konstantinos Gaitanis on 02.05.23.
////

import XCTest
import IcpKit

final class ICPIntegrationTests: XCTestCase {
    private let client = ICPRequestClient()
    
    func testAccountBalance() async throws {
        let balance = try await ICPLedgerCanister.accountBalance(.uncertified, of: mainAccount1, client)
        print("Test Wallet 1 - Main Account Balance: \(balance)")
    }

    func testReadState() async throws {
        let response = try await client.readState(paths: ["time"], effectiveCanister: ICPSystemCanisters.ledger)
        guard let timeLeb128 = response.rawValueForPath(endingWith: "time") else {
            XCTFail()
            return
        }
        let timeSince1970s: Int = try ICPCryptography.Leb128.decodeUnsigned(timeLeb128) / 1_000_000_000
        let time = Date(timeIntervalSince1970: TimeInterval(timeSince1970s))
        XCTAssertGreaterThan(.now, time)
        XCTAssertGreaterThan(time.addingTimeInterval(10), .now)
    }
    
//    func testReadStateSigned() async throws {
//        let response = try await client.readState(paths: ["time"], effectiveCanister: ICPSystemCanisters.ledger, sender: signingPrincipal1)
//        print(response)
//    }
//    
//    func testTransfer() async throws {
//        let block = try await ICPLedgerCanister.transfer(
//            from: mainAccount1,
//            to: mainAccount1.accountId.hex,
//            amount: 10000,
//            signingPrincipal: signingPrincipal1,
//            client)
//        print("Transaction sent in block \(block)")
//    }
    
    func testQueryBlock() async throws {
        do {
            let _ = try await ICPLedgerCanister.queryBlock(index: UInt64.max, client)
        } catch ICPLedgerCanisterError.blockNotFound {
            XCTAssert(true)
        } catch {
            XCTFail()
        }
    }
}

private let testWallet1PublicKey: Data = Data.fromHex("046acf4c93dd993cd736420302eb70da254532ec3179250a21eec4ce823ff289aaa382cb19576b2c6447db09cb45926ebd69ce288b1804580fe62c343d3252ec6e")!
private let testWallet2PublicKey: Data = Data.fromHex("04723cdc9bd653014a501159fb89dcc6e2cf03f242955b987b53dd6193815d8a9d4a4f5b902b2819d270c28f0710ad96fea5b13f5fe30c6e244bf2941ebf4ec36e")!

private let principal1 = try! ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: testWallet1PublicKey)
private let mainAccount1 = try! ICPAccount.mainAccount(of: principal1)


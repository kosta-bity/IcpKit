//
//  ICPHttpRequestTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import XCTest
import PotentCBOR
@testable import IcpKit
@testable import RealHTTP

final class ICPHttpRequestTests: XCTestCase {

    func testReadStateHttpRequest() async throws {
        let readStateRequest = try await ICPRequest(
            .readState(paths: []),
            canister: ICPSystemCanisters.ledger
        )
        let httpRequest = readStateRequest.httpRequest
        XCTAssertEqual(httpRequest.method, .post)
        XCTAssertEqual(httpRequest.url?.absoluteString, "https://icp-api.io/api/v2/canister/\(ICPSystemCanisters.ledger.string)/read_state")
        XCTAssertTrue(httpRequest.body.headers.contains(.contentType("application/cbor")))
        
        let cborBody = httpRequest.body.asData!
        XCTAssertEqual(cborBody.prefix(3), Data([0xD9, 0xD9, 0xF7]))
        let cborBodyWithoutTag = Data(cborBody.suffix(from: 3)) // ignore the self describing tag
        let decodedBody = try CBORDecoder.default.decode(ReadRequestDecodable.self, from: cborBodyWithoutTag)
        
        XCTAssertEqual(decodedBody.content.request_type, "read_state")
        //XCTAssertEqual(decodedBody.content.sender, principal1.bytes)
        XCTAssertEqual(decodedBody.content.nonce.count, 32)
        let expiry = Date(timeIntervalSince1970: TimeInterval(decodedBody.content.ingress_expiry / 1_000_000_000))
        XCTAssertLessThanOrEqual(Date.now.advanced(by: ICPRequestBuilder.defaultIngressExpirySeconds-1), expiry)
        XCTAssertGreaterThan(Date.now.advanced(by: ICPRequestBuilder.defaultIngressExpirySeconds+1), expiry)
    }
}

private struct ReadRequestDecodable: Decodable {
    let content: Content
    let sender_pubkey: Data?
    let sender_sig: Data?
    
    struct Content: Decodable {
        let request_type: String
        let sender: Data
        let nonce: Data
        let ingress_expiry: Int
        let paths: [[Data]]
    }
}

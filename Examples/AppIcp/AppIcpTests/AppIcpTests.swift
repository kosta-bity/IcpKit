//
//  AppIcpTests.swift
//  AppIcpTests
//
//  Created by Konstantinos Gaitanis on 16.07.24.
//

import XCTest
import IcpKit
import BigInt
@testable import AppIcp

final class AppIcpTests: XCTestCase {
    func testIcrc7() async throws {
        let client = ICPRequestClient()
        let service = try Icrc7Service(canister: ICPPrincipal("xyo2o-gyaaa-aaaal-qb55a-cai"), client: client)
//        let symbol = try await service.icrc7_symbol()
//        print(symbol)
        let collectionMetaData = try await service.icrc7_collection_metadata()
        print(collectionMetaData)
        let tokenMetadata = try await service.icrc7_token_metadata(token_ids: [BigUInt("220006664755056617740679098655037441121118878992453416312888872764769238635723484506702969338593331")])
        print(tokenMetadata)
        let tokens = try await service.icrc7_tokens(prev: nil, take: nil)
        print(tokens)
    }

}

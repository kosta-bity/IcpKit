//
//  ICPTokenActor.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import IcpKit
import BigInt

public struct ICPTokenTransferArgs {
    public let sender: ICPSigningPrincipal
    public let from: ICPAccount
    public let to: ICPAccount
    public let amount: BigUInt
    
    // options
    public let fee: BigUInt?
    public let memo: String?
    public let createdAtTime: Date?
}

public struct ICPTokenApproveArgs {
    public let spender: ICPPrincipal
    public let amount: BigUInt
    public let nonce: BigUInt?
}

public enum ICPTokenApproveResult {
    case ok(String)
    case error
}

public enum ICPTokenTransferResponse {
    case height(BigUInt)
    case amount(String)
    case transactionId(String)
}

public protocol ICPTokenActor {
    var standard: ICPTokenStandard { get }

    init(_ canister: ICPPrincipal, _ client: ICPRequestClient)
    
    func fee() async throws -> BigUInt
    func metaData() async throws -> ICPTokenMetadata
    
    func balance(_ principal: ICPPrincipal) async throws -> BigUInt
    func transfer(_ args: ICPTokenTransferArgs) async throws -> ICPTokenTransferResponse
    func approve(_ args: ICPTokenApproveArgs) async throws -> ICPTokenApproveResult
}

public extension ICPTokenActor {
    init(_ canister: String, _ client: ICPRequestClient) throws {
        self.init(try ICPPrincipal(canister), client)
    }
}

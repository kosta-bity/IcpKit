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
    
    public init(sender: ICPSigningPrincipal, from: ICPAccount, to: ICPAccount, amount: BigUInt, fee: BigUInt?, memo: String?, createdAtTime: Date?) {
        self.sender = sender
        self.from = from
        self.to = to
        self.amount = amount
        self.fee = fee
        self.memo = memo
        self.createdAtTime = createdAtTime
    }
}

public struct ICPTokenApproveArgs {
    public let sender: ICPSigningPrincipal
    public let spender: ICPPrincipal
    public let amount: BigUInt
    public let memo: Data?
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
    func transactions(of user: ICPPrincipal) async throws -> [ICPTokenTransaction]
    
    func transfer(_ args: ICPTokenTransferArgs) async throws -> ICPTokenTransferResponse
    func approve(_ args: ICPTokenApproveArgs) async throws
}

public extension ICPTokenActor {
    init(_ canister: String, _ client: ICPRequestClient) throws {
        self.init(try ICPPrincipal(canister), client)
    }
}

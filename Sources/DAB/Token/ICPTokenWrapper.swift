//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import Candid
import BigInt

public struct ICPTokenBalanceResponse {
    public let value: BigUInt
    public let decimals: Int
    public let error: String?
}

public struct ICPTokenTransferArgs {
    public let to: any CandidPrincipalProtocol
    public let from: any CandidPrincipalProtocol
    public let amount: BigUInt
    
    // options
    public let fee: BigUInt?
    public let memo: String?
    public let fromSubAccount: BigUInt?
    public let toSubAccount: Data? // or BigUInt?
    public let createdAtTime: Date?
}

public struct ICPTokenApproveArgs {
    public let spender: any CandidPrincipalProtocol
    public let amount: BigUInt
    public let nonce: BigUInt?
}

public enum ICPTokenApproveResult {
    case ok(String)
    case error
}

public enum ICPTokenTransferResponse {
    case height(String)
    case amount(String)
    case transactionId(String)
}

public protocol ICPTokenWrapper {
    var standard: ICPTokenStandard { get }
    
    func balance(_ principal: any CandidPrincipalProtocol) async throws -> ICPTokenBalanceResponse
    func transfer(_ args: ICPTokenTransferArgs) async throws -> ICPTokenTransferResponse
    func approve(_ args: ICPTokenApproveArgs) async throws -> ICPTokenApproveResult
    func metadata() async throws -> ICPTokenMetadata
    func decimals() async throws -> Int
}

//
//  ICPTokenTransaction.swift
//
//
//  Created by Konstantinos Gaitanis on 10.09.24.
//

import Foundation
import IcpKit
import BigInt

public struct ICPTokenTransaction {
    public enum Operation {
        case mint
        case approve
        case transfer
        case transferFrom
    }
    public enum Status {
        case failed
        case succeeded
    }
    
    public let operation: Operation
    public let from: ICPPrincipal
    public let to: ICPPrincipal
    public let amount: BigUInt
    public let fee: BigUInt
    public let status: Status
    public let timeStamp: Date
    public let caller: ICPPrincipal?
    /// The block height
    public let index: BigUInt
    /// The token canister
    public let canister: ICPPrincipal
}

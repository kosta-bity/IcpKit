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
        case mint(to: ICPAccount)
        case burn(from: ICPAccount)
        case approve(from: ICPAccount, expectedAllowance: BigUInt?, expires: Date?) //spender
        case transfer(from: ICPAccount, to: ICPAccount)
    }
    /// The block height
    public let index: BigUInt
    public let operation: Operation
    public let memo: Data?
    public let amount: BigUInt
    public let fee: BigUInt
    public let created: Date?
    public let timeStamp: Date
    public let spender: ICPAccount?
    public let tokenCanister: ICPPrincipal
    
    public var from: ICPAccount? {
        switch operation {
        case .mint: return nil
        case .transfer(let from, _),
             .approve(let from, _, _),
             .burn(let from):
            return from
        }
    }
    
    public var to: ICPAccount? {
        switch operation {
        case .mint(let to),
             .transfer(_, let to): return to
        case .approve, .burn:
            return nil
        }
    }
}


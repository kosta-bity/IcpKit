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
    public enum Destination {
        case accountId(String)
        case account(ICPAccount)
    }
    
    public enum Operation {
        case mint(to: Destination)
        case burn(from: Destination)
        case approve(from: Destination, expectedAllowance: BigUInt?, expires: Date?) //spender
        case transfer(from: Destination, to: Destination)
    }
    /// The block height
    public let index: BigUInt
    public let operation: Operation
    public let memo: Data?
    public let amount: BigUInt
    public let fee: BigUInt
    public let created: Date?
    public let timeStamp: Date?
    public let spender: Destination?
    public let tokenCanister: ICPPrincipal
    
    public var from: Destination? {
        switch operation {
        case .mint: return nil
        case .transfer(let from, _),
             .approve(let from, _, _),
             .burn(let from):
            return from
        }
    }
    
    public var to: Destination? {
        switch operation {
        case .mint(let to),
             .transfer(_, let to): return to
        case .approve, .burn:
            return nil
        }
    }
}


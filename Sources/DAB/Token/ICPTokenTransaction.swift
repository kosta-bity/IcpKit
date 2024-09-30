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
        
        public var address: String {
            switch self {
            case .accountId(let address): return address
            case .account(let icpAccount): return icpAccount.address
            }
        }
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
    public let token: ICPToken
    
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
    
    public init(index: BigUInt, operation: Operation, memo: Data?, amount: BigUInt, fee: BigUInt, created: Date?, timeStamp: Date?, spender: Destination?, token: ICPToken) {
        self.index = index
        self.operation = operation
        self.memo = memo
        self.amount = amount
        self.fee = fee
        self.created = created
        self.timeStamp = timeStamp
        self.spender = spender
        self.token = token
    }
}


//
//  ICPBlock.swift
//
//  Created by Konstantinos Gaitanis on 16.05.23.
//

import Foundation

public struct ICPBlock {
    public let parentHash: Data
    public let timestamp: UInt64
    public let transaction: Transaction
    
    public struct Transaction {
        public let memo: UInt64
        public let createdNanos: UInt64
        public let operation: Operation
        
        public enum Operation {
            case approve(from: Data, allowance: UInt64, expectedAllowance: UInt64?, fee: UInt64, expiresAt: Date?, spender: Data)
            case burn(from: Data, amount: UInt64, spender: Data?)
            case mint(to: Data, amount: UInt64)
            case transfer(from: Data, to: Data, amount: UInt64, fee: UInt64, spender: Data?)
            
            public var amount: UInt64 {
                switch self {
                case .approve(_, let amount, _, _, _, _),
                     .burn(_, let amount, _),
                     .mint(_, let amount),
                     .transfer(_,_, let amount, _, _):
                    return amount
                }
            }
            
            public var fee: UInt64? {
                switch self {
                case .approve(_,_,_, let fee, _,_),
                     .transfer(_,_,_, let fee, _):
                    return fee
                default: return nil
                }
            }
        }
    }
    
    public func icpTransaction(blockIndex: UInt, hash: Data) -> ICPTransaction {
        return ICPTransaction(
            type: .from(transaction.operation),
            amount: UInt(transaction.operation.amount),
            fee: transaction.operation.fee == nil ? nil : UInt(transaction.operation.fee!),
            hash: hash,
            blockIndex: blockIndex,
            memo: transaction.memo,
            createdNanos: transaction.createdNanos
        )
    }
}

private extension ICPTransactionType {
    static func from(_ operation: ICPBlock.Transaction.Operation) -> ICPTransactionType {
        switch operation {
        case .approve(let from, _, _, _, _, _): return .approve(from: from.hex)
        case .burn(let from, _, _): return .burn(from: from.hex)
        case .mint(let to, _): return .mint(to: to.hex)
        case .transfer(let from, let to, _, _, _): return .send(from: from.hex, to: to.hex)
        }
    }
}

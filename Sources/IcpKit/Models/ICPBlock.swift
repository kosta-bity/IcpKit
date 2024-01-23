//
//  ICPBlock.swift
//  Runner
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
            case burn(from: Data, amount: UInt64)
            case mint(to: Data, amount: UInt64)
            case transfer(from: Data, to: Data, amount: UInt64, fee: UInt64)
            
            public var amount: UInt64 {
                switch self {
                case .burn(_, let amount),
                     .mint(_, let amount),
                     .transfer(_,_, let amount, _):
                    return amount
                }
            }
            
            public var fee: UInt64? {
                guard case .transfer(_,_,_, let fee) = self else { return nil }
                return fee
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
        case .burn(let from, _): return .burn(from: from.hex)
        case .mint(let to, _): return .mint(to: to.hex)
        case .transfer(let from, let to, _, _): return .send(from: from.hex, to: to.hex)
        }
    }
}

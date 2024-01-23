//
//  ICPTransaction.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 10.05.23.
//

import Foundation

public enum ICPTransactionType {
    // account Identifiers
    case mint(to: String)
    case burn(from: String)
    case send(from: String, to: String)
    
    public var from: String? {
        switch self {
        case .mint: return nil
        case .burn(let from), .send(let from, _):
            return from
        }
    }
    
    public var to: String? {
        switch self {
        case .burn: return nil
        case .mint(let to), .send(_, let to): return to
        }
    }
}

public struct ICPTransaction {
    public let type: ICPTransactionType
    public let amount: UInt
    public let fee: UInt?
    public let hash: Data
    public let blockIndex: UInt
    public let memo: UInt64
    public let createdNanos: UInt64
    public var created: Date { Date(timeIntervalSince1970: Double(createdNanos) / 1_000_000_000) }
    
    public init(type: ICPTransactionType, amount: UInt, fee: UInt?, hash: Data, blockIndex: UInt, memo: UInt64, createdNanos: UInt64) {
        self.type = type
        self.amount = amount
        self.fee = fee
        self.hash = hash
        self.blockIndex = blockIndex
        self.memo = memo
        self.createdNanos = createdNanos
    }
}

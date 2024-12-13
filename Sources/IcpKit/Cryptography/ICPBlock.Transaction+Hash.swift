//
//  ICPBlock.Transaction+Hash.swift
//
//  Created by Konstantinos Gaitanis on 16.11.23.
//

import Foundation
import PotentCBOR

public extension ICPCryptography {
    /// https://internetcomputer.org/docs/current/references/ledger#_chaining_ledger_blocks
    static func transactionHash(_ transaction: ICPBlock.Transaction) throws -> Data {
        let serialised = try CBORSerialization.data(from: transaction.cbor)
        let txHash = ICPCryptography.sha256(serialised)
        return txHash
    }
    
    static func transactionHash(_ operation: ICPBlock.Transaction.Operation, memo: UInt64, createdNanos: UInt64) throws -> Data {
        try transactionHash(ICPBlock.Transaction(memo: memo, createdNanos: createdNanos, operation: operation))
    }
}

private extension ICPBlock.Transaction {
    var cbor: CBOR {
        [
            0: operation.cbor,
            1: CBOR(memo),
            2: [0: CBOR(createdNanos)]
        ]
    }
}

private extension ICPBlock.Transaction.Operation {
    var cbor: CBOR {
        switch self {
        case .burn(let from, let amount, _):
            return [
                0: [
                    0: CBOR(from.hex),
                    1: CBOR(amount),
                ]
            ]
        case .mint(let to, let amount):
            return [
                1: [
                    0: CBOR(to.hex),
                    1: CBOR(amount),
                ]
            ]
        case .transfer(let from, let to, let amount, let fee, _):
            return [
                2: [
                    0: CBOR(from.hex),
                    1: CBOR(to.hex),
                    2: [0: CBOR(amount)],
                    3: [0: CBOR(fee)],
                ]
            ]
        default: return nil
            // TODO: Can not find any docs for this...
//        case .approve(let from, let allowance, _, let fee, _, let spender):
//            return [
//                3: [
//                    0: CBOR(from.hex),
//                    1: CBOR(spender.hex),
//                    2: [0: CBOR(allowance)],
//                    3: [0: CBOR(fee)],
//                ]
//            ]
        }
    }
}

//
//  ICPBlock.Transaction+Hash.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 16.11.23.
//

import Foundation
import PotentCBOR

public extension ICPCryptography {
    static func transactionHash(_ transaction: ICPBlock.Transaction) throws -> Data {
        let serialised = try CBORSerialization.data(from: transaction.cbor)
        let txHash = Cryptography.sha256(serialised)
        return txHash
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
        case .burn(from: let from, amount: let amount):
            return [
                0: [
                    0: CBOR(from.hex),
                    1: CBOR(amount),
                ]
            ]
        case .mint(to: let to, amount: let amount):
            return [
                1: [
                    0: CBOR(to.hex),
                    1: CBOR(amount),
                ]
            ]
        case .transfer(from: let from, to: let to, amount: let amount, fee: let fee):
            return [
                2: [
                    0: CBOR(from.hex),
                    1: CBOR(to.hex),
                    2: [0: CBOR(amount)],
                    3: [0: CBOR(fee)],
                ]
            ]
        }
    }
}

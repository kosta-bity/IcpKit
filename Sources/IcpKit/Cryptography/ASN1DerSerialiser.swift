//
//  ASN1DerSerializer.swift
//
//  Created by Konstantinos Gaitanis on 20.04.23.
//

import Foundation
import PotentASN1

// https://www.ibm.com/docs/en/zos/2.1.0?topic=programming-object-identifiers
private enum ObjectIdentifiers {
    static let ecPublicKey: ASN1 = .objectIdentifier([1, 2, 840, 10045, 2, 1])  // Asymmetric Encryption Algorithms: ECC (ecPublicKey)
    static let secp256k1: ASN1 = .objectIdentifier([1, 3, 132, 0, 10])          // ECC Name Curves: Secp256k1
}

extension ICPCryptography {
    enum DERSerialisationError: Error {
        case invalidEcPublicKey
    }
    static func der(uncompressedEcPublicKey publicKey: Data) throws -> Data {
        guard publicKey.count == 65,
              publicKey.first == 0x04 else {
            throw DERSerialisationError.invalidEcPublicKey
        }
        let encoded = try PotentASN1.ASN1Serialization.der(from:
            .sequence([
                .sequence([
                    ObjectIdentifiers.ecPublicKey,
                    ObjectIdentifiers.secp256k1
                ]),
                .bitString(0, publicKey)    // not sure why we pass 0 here
            ])
        )
        return encoded
    }
}

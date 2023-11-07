//
//  EllipticSign.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import HsCryptoKit

extension Cryptography {
    /// secp256k1
    static func ellipticSign(_ message: any DataProtocol, privateKey: Data) throws -> Data {
        var signature = try HsCryptoKit.Crypto.ellipticSign(Data(message), privateKey: privateKey)
        // signature is 65 bytes. last byte is the recid (see https://bitcoin.stackexchange.com/questions/38351/ecdsa-v-r-s-what-is-v)
        // For bitcoin/ethereum signing we add 0x1b to the last byte (recid)
        signature[64] += 0x1b // 27
        return signature
    }
}

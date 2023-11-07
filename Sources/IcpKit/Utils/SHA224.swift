//
//  SHA224.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 19.04.23.
//

import Foundation
import CommonCrypto

extension Cryptography {
    static func sha224(_ message: any DataProtocol) -> Data {
        let length = CommonCrypto.CC_SHA224_DIGEST_LENGTH
        var digest = Data(count: Int(length))
        
        _ = digest.withUnsafeMutableBytes { digestBytes in
            Data(message).withUnsafeBytes { messageBytes in
                CommonCrypto.CC_SHA224(messageBytes.baseAddress, CC_LONG(message.count), digestBytes.baseAddress)
            }
        }
        
        return digest
    }
}

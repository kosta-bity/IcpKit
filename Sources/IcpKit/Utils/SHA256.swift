//
//  SHA256.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import CryptoKit

enum Cryptography {
    static func sha256(_ data: any DataProtocol) -> Data {
        return CryptoKit.SHA256.hash(data: data).data
    }
}

private extension CryptoKit.Digest {
    var data: Data { Data(makeIterator()) }
}

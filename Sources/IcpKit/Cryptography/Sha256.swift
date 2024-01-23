//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 23.01.24.
//

import Foundation
import CryptoKit

public extension ICPCryptography {
    static func sha256(_ data: any DataProtocol) -> Data {
        return CryptoKit.SHA256.hash(data: data).data
    }
}

private extension CryptoKit.Digest {
    var data: Data { Data(makeIterator()) }
}

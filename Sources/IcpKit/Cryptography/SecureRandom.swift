//
//  SecureRandom.swift
//
//
//  Created by Konstantinos Gaitanis on 23.01.24.
//

import Foundation

extension ICPCryptography {
    struct SecureRandomGenerationError: Error {
        let status: Int32
    }
    
    static func secureRandom(_ length: Int) throws -> Data {
        var bytes = Array(repeating: UInt8.zero, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw SecureRandomGenerationError(status: status)
        }
        return Data(bytes)
    }
}

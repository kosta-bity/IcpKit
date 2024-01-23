//
//  SelfAuthenticatingId.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import Foundation

public extension ICPCryptography {
    /// Principal with Self-Authenticating ID
    /// These have the form H(ec_public_key) · 0x02 (29 bytes).
    /// ec_public_key in raw uncompressed form (65 bytes) 0x04·X·Y
    static func selfAuthenticatingPrincipal(uncompressedPublicKey publicKey: Data) throws -> ICPPrincipal {
        let serialized = try Cryptography.der(uncompressedEcPublicKey: publicKey)
        let hash = Cryptography.sha224(serialized)
        let bytes = hash + Data([0x02])
        return ICPPrincipal(bytes)
    }
}

//
//  ICPSignature.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 26.04.23.
//

import Foundation

public extension ICPCryptography {
    /// https://internetcomputer.org/docs/current/references/ic-interface-spec/#signatures
    /// Signatures are domain separated, which means that every message is prefixed with a byte string that is unique to the purpose of the signature.
    /// The domain separators are prefix-free by construction, as their first byte indicates their length.
    public static func ellipticSign(_ message: any DataProtocol, domain: ICPDomainSeparator, with key: Data) throws -> Data {
        let domainSeparatedData = domain.domainSeparatedData(message)
        let hashedMessage = Cryptography.sha256(domainSeparatedData)
        let extendedSignature = try Cryptography.ellipticSign(hashedMessage, privateKey: key)
        return extendedSignature
    }
    
    public static func verifyBlsSignature(message: any DataProtocol, publicKey: any DataProtocol, signature: any DataProtocol) throws {
        // TODO: Link to Rust library
        return
//        guard let _ = bls_instance else {
//            throw BlsRustError.notInstantiated
//        }
//        try Data(signature).withUnsafeBytes { signaturePointer in
//            try Data(message).withUnsafeBytes { messagePointer in
//                try Data(publicKey).withUnsafeBytes { publicKeyPointer in
//                    let i = bls_verify(signature.count, signaturePointer.baseAddress,
//                                       message.count, messagePointer.baseAddress,
//                                       publicKey.count, publicKeyPointer.baseAddress)
//                    guard i == 1 else {
//                        throw ICPStateCertificateError.invalidSignature
//                    }
//                }
//            }
//        }
    }
    
//    private static let bls_instance = BlsInstance()
}

//private enum BlsRustError: Error {
//    case notInstantiated
//}
//
//private class BlsInstance {
//    init?() {
//        guard bls_instantiate() == 1 else { return nil }
//    }
//}

//
//  ICPCryptography+Account.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import Foundation
import secp256k1

public extension ICPCryptography {
    enum ICPAccountError: Error {
        case invalidSubAccountId
    }    
    
    /// https://internetcomputer.org/docs/current/developer-docs/integrations/icrc-1/#account
    static func accountId(of principal: ICPPrincipal, subAccountId: Data) throws -> Data {
        guard subAccountId.count == 32 else {
            throw ICPAccountError.invalidSubAccountId
        }
        let data = Self.domain.data +
                   principal.bytes +
                   subAccountId.bytes
        
        let hashed = Cryptography.sha224(data)
        let checksum = Cryptography.crc32(hashed)
        let accountId = checksum + hashed
        return accountId
    }
    
    static func validateAccountId(_ accountId: String) -> Bool {
        guard let data = Data.fromHex(accountId),
              data.count == 32 else {
            return false
        }
        let checksum = data.prefix(Cryptography.crc32Length)
        let hashed = data.suffix(from: Cryptography.crc32Length)
        let expectedChecksum = Cryptography.crc32(hashed)
        return checksum == expectedChecksum
    }
    
    private static let domain: ICPDomainSeparator = "account-id"
}

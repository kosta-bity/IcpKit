//
//  ICPCryptography+Account.swift
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import Foundation
import Base32
import Candid

public extension ICPCryptography {
    enum ICPAccountError: Error {
        case invalidSubAccountId
    }    
    
    /// https://internetcomputer.org/docs/current/developer-docs/integrations/icrc-1/#account
    static func accountId(of principal: ICPPrincipal, subAccountId: Data) throws -> Data {
        guard subAccountId.count == ICPAccount.subAccountIdLength else {
            throw ICPAccountError.invalidSubAccountId
        }
        let data = Self.domain.data +
                   principal.bytes +
                   subAccountId

        let hashed = ICPCryptography.sha224(data)
        let checksum = CRC32.checksum(hashed)
        let accountId = checksum + hashed
        return accountId
    }
    
    static func validateAccountId(_ accountId: String) -> Bool {
        guard let data = Data.fromHex(accountId),
              data.count == 32 else {
            return false
        }
        let checksum = data.prefix(CRC32.length)
        let hashed = data.suffix(from: CRC32.length)
        let expectedChecksum = CRC32.checksum(hashed)
        return checksum == expectedChecksum
    }
    
    private static let domain: ICPDomainSeparator = "account-id"
}

public extension ICPAccount {
    enum ICPAccountError: Error {
        case invalidTextualRepresentation
        case invalidChecksum
    }
    /// https://github.com/dfinity/ICRC-1/blob/main/standards/ICRC-1/TextualEncoding.md
    /// Account.toText({ owner; ?subaccount }) = {
    ///     let checksum = bigEndianBytes(crc32(concatBytes(Principal.toBytes(owner), subaccount)));
    ///     Principal.toText(owner) # '-' # base32LowerCaseNoPadding(checksum) # '.' # trimLeading('0', hex(subaccount))
    /// }
    func textualRepresentation() -> String {
        guard subAccountId != Self.defaultSubAccountId else {
            return principal.string
        }
        let checksum = Self.checksum(principal, subAccountId)
        let hexSubAccount = subAccountId.hex.trimmingPrefix(while: { $0 == "0" })
        return "\(principal.string)-\(checksum).\(hexSubAccount)"
    }
    
    init(textualRepresentation: String) throws {
        if textualRepresentation.contains(".") {
            // three parts : aaaaa-aa-checksum.subAccountId
            let dotSplit = textualRepresentation.split(separator: ".")
            guard dotSplit.count == 2 else {
                throw ICPAccountError.invalidTextualRepresentation
            }
            var subAccountString = dotSplit[1]
            if subAccountString.count % 2 == 1 { subAccountString = "0" + subAccountString }
            guard var subAccountId = Data.fromHex(subAccountString) else {
                throw ICPAccountError.invalidTextualRepresentation
            }
            subAccountId = subAccountId + Data(repeating: 0, count: Self.subAccountIdLength - subAccountId.count)
            let dashSplit = dotSplit[0].split(separator: "-")
            guard dashSplit.count >= 3,
                  let checksumString = dashSplit.last else {
                throw ICPAccountError.invalidTextualRepresentation
            }
            let principalString = dashSplit.prefix(upTo: dashSplit.count - 1).joined(separator: "-")
            let principal = try ICPPrincipal(principalString)
            let expectedChecksum = Self.checksum(principal, subAccountId)
            guard checksumString == expectedChecksum else {
                throw ICPAccountError.invalidChecksum
            }
            try self.init(principal: principal, subAccountId: subAccountId)
            
        } else {
            // principal only
            try self.init(principal: try ICPPrincipal(textualRepresentation), subAccountId: Self.defaultSubAccountId)
        }
    }
    
    private static func checksum(_ principal: ICPPrincipal, _ subAccountId: Data) -> String {
        let checksum = CRC32.checksum(principal.bytes + subAccountId)
        let base32Checksum = Base32.encode(checksum, options: .letterCase(.lower), .pad(false))
        return base32Checksum
    }
}

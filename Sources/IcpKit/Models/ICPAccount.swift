//
//  ICPAccount.swift
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import Candid
import Base32

public struct ICPAccount {
    public let principal: ICPPrincipal
    public var address: String { accountId.hex }
    public let accountId: Data
    public let subAccountId: Data
    
    public init(principal: ICPPrincipal, subAccountId: Data) throws {
        self.principal = principal
        self.subAccountId = subAccountId
        self.accountId = try ICPCryptography.accountId(of: principal, subAccountId: subAccountId)
    }
        
    public static func mainAccount(of principal: ICPPrincipal) -> ICPAccount {
        return try! ICPAccount(
            principal: principal,
            subAccountId: defaultSubAccountId
        )
    }
    
    /// https://github.com/dfinity/ICRC-1/blob/main/standards/ICRC-1/TextualEncoding.md
    /// Account.toText({ owner; ?subaccount }) = {
    ///     let checksum = bigEndianBytes(crc32(concatBytes(Principal.toBytes(owner), subaccount)));
    ///     Principal.toText(owner) # '-' # base32LowerCaseNoPadding(checksum) # '.' # trimLeading('0', hex(subaccount))
    /// }
    public func textualRepresentation() -> String {
        guard subAccountId != Self.defaultSubAccountId else {
            return principal.string
        }
        let checksum = CRC32.checksum(principal.bytes + subAccountId)
        let base32Checksum = Base32.encode(checksum, options: .letterCase(.lower), .pad(false))
        let hexSubAccount = subAccountId.hex.trimmingPrefix(while: { $0 == "0" })
        return "\(principal.string)-\(base32Checksum).\(hexSubAccount)"
    }
    
    private static let defaultSubAccountId = Data(repeating: 0, count: 32)
}



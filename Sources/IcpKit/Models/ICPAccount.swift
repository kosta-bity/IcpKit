//
//  ICPAccount.swift
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import Candid

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
    public static let subAccountIdLength = 32
    public static let defaultSubAccountId = Data(repeating: 0, count: subAccountIdLength)
}



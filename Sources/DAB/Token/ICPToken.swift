//
//  ICPToken.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import IcpKit
import BigInt

public struct ICPToken {
    public let standard: ICPTokenStandard
    
    public let canister: ICPPrincipal
    public let name: String
    public let decimals: UInt
    public let symbol: String
    public let description: String
    public let totalSupply: BigUInt
    public let verified: Bool
    
    public let logo: URL?
    public let website: URL?
    
    public init(standard: ICPTokenStandard, canister: ICPPrincipal, name: String, decimals: UInt, symbol: String, description: String, totalSupply: BigUInt, verified: Bool, logo: URL?, website: URL?) {
        self.standard = standard
        self.canister = canister
        self.name = name
        self.decimals = decimals
        self.symbol = symbol
        self.description = description
        self.totalSupply = totalSupply
        self.verified = verified
        self.logo = logo
        self.website = website
    }
}

extension ICPToken: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(canister.bytes)
    }
}

public extension ICPToken {
    func decimal(_ amount: BigUInt) -> Decimal {
        let base = BigUInt(10).power(Int(decimals))
        let decimal = Decimal(exactly: amount)! / Decimal(exactly: base)!
        return decimal
    }
}

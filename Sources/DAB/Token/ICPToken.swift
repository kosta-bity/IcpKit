//
//  ICPToken.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import IcpKit
import BigInt

public struct ICPToken: Sendable {
    public let standard: ICPTokenStandard
    
    public let canister: ICPPrincipal
    public let name: String
    public let decimals: UInt
    public let symbol: String
    public let verified: Bool
    
    public let logo: URL?
    
    public init(standard: ICPTokenStandard, canister: ICPPrincipal, name: String, decimals: UInt, symbol: String, verified: Bool, logo: URL?) {
        self.standard = standard
        self.canister = canister
        self.name = name
        self.decimals = decimals
        self.symbol = symbol
        self.verified = verified
        self.logo = logo
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

extension ICPToken {
    init(standard: ICPTokenStandard, canister: ICPPrincipal, metadata: ICPTokenMetadata, verified: Bool = true) {
        self.standard = standard
        self.canister = canister
        self.verified = verified
        name = metadata.name
        symbol = metadata.symbol
        decimals = UInt(metadata.decimals)
        logo = metadata.logo
        
    }
}

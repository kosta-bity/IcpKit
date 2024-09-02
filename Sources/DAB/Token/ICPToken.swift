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
}

extension ICPToken: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(canister.bytes)
    }
}

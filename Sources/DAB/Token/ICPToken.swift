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
    
    public let name: String
    public let symbol: String
    public let description: String
    public let totalSupply: BigUInt
    
    public let logo: URL
    public let website: URL
    public let principal: ICPPrincipal
    
}

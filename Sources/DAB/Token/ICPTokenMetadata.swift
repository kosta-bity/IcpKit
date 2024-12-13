//
//  ICPTokenMetadata.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import BigInt

public struct ICPTokenMetadata {
    public let name: String
    public let symbol: String
    public let decimals: Int
    public let totalSupply: BigUInt?
    public let logo: URL?
    public let fee: BigUInt
}

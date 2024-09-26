//
//  ICPTokenBalance.swift
//  
//
//  Created by Konstantinos Gaitanis on 06.09.24.
//

import Foundation
import BigInt

public struct ICPTokenBalance {
    public let token: ICPToken
    public let balance: BigUInt
    
    public init(token: ICPToken, balance: BigUInt) {
        self.token = token
        self.balance = balance
    }
}

public extension ICPTokenBalance {
    var decimalBalance: Decimal { token.decimal(balance) }
}

extension ICPTokenBalance: CustomStringConvertible {
    public var description: String { "\(token.name): \(decimalBalance)" }
}

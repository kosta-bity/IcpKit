//
//  TokenBalance.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 03.09.24.
//

import SwiftUI
import DAB
import BigInt

struct TokenBalance: View {
    let holding: TokenHolding
    
    private var token: ICPToken { holding.token }
    
    var body: some View {
        HStack {
            RemoteImage(token.logo)
                .frame(width: 20, height: 20)
            Text(token.name)
            Spacer()
            Text(holding.balanceString)
            Text(token.symbol)
        }
    }
}

#Preview {
    TokenBalance(holding: PreviewModels.mockHolding[3])
}

private extension TokenHolding {
    var balanceString: String {
        let base = BigUInt(10).power(Int(token.decimals))
        let decimal = Decimal(exactly: balance)! / Decimal(exactly: base)!
        return decimal.formatted()
    }
}

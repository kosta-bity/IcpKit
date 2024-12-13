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
    let holding: ICPTokenBalance
    
    private var token: ICPToken { holding.token }
    
    var body: some View {
        HStack {
            RemoteImage(token.logo)
                .frame(width: 20, height: 20)
            Text(token.name)
            Spacer()
            Text(holding.decimalBalance.formatted())
            Text(token.symbol)
        }
    }
}

#Preview {
    TokenBalance(holding: PreviewModels.mockHolding[3])
}

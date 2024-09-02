//
//  TokenDetails.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import SwiftUI
import DAB

struct TokenDetails: View {
    let token: ICPToken
    
    var body: some View {
        ScrollView {
            VStack {
                RemoteImage(token.logo)
                    .frame(minHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .tagged(token.standard.description)
                Text(token.name)
                    .bold()
                    .font(.title3)
                ItemProperty(label: "Symbol", value: token.symbol)
                ItemProperty(label: "Decimals", value: String(token.decimals))
                ItemProperty(label: "Total supply", value: String(token.totalSupply))
                ItemProperty(label: "Description", value: token.description)
                ItemProperty(label: "Verified", value: String(token.verified))
                ItemProperty(label: "Canister", value: token.canister.string)
                token.website.map { ItemProperty(label: "Website", value: $0.absoluteString) }
            }
        }
        .safeAreaPadding()
        .navigationTitle(token.name)
    }
}

#Preview {
    TokenDetails(token: PreviewModels.mockToken)
}

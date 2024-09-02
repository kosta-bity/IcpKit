//
//  NftDetails.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import DAB

struct NftDetails: View {
    let nft: ICPNftDetails
    
    var body: some View {
        ScrollView {
            VStack {                
                RemoteImage(nft.url)
                .frame(minHeight: 150)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                nft.name.map { Text($0)
                        .bold()
                        .font(.title3)
                }
                NftProperty(label: "ID", value: nft.id)
                NftProperty(label: "Index", value: nft.index.description)
                NftProperty(label: "Canister", value: nft.canister.string)
                NftProperty(label: "Metadata", value: nft.metadata.debugDescription)
            }
        }
        .safeAreaPadding()
        .navigationTitle(nft.name ?? nft.id.description)
    }
}

#Preview {
    NftDetails(nft: PreviewModels.mockNft)
}

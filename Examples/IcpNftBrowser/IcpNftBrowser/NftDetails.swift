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
                AsyncImage(url: nft.url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else if phase.error != nil {
                        Color.red // Indicates an error.
                    } else {
                        ProgressView()
                    }
                }
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

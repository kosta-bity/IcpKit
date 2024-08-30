//
//  NftCollectionDetails.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import DAB

struct NftCollectionDetails: View {
    @StateObject var controller: CollectionController
    @State private var presentingNft: ICPNftDetails?
    
    var body: some View {
        SheetPresenter(
            presenting: $presentingNft,
            builder: NftDetails.init
        ) {
            ScrollView {
                VStack {
                    AsyncImage(url: controller.collection.icon) { phase in
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
                    Text(controller.collection.description)
                        .lineLimit(.max)
                    Divider()
                    Lazy2dGrid(items: $controller.nfts) { nft in
                        NftPreview(nft: nft).onTapGesture { presentingNft = nft }
                    }
                }
            }
        }
        .navigationTitle(controller.collection.name)
    }
}

#Preview {
    NftCollectionDetails(controller: PreviewModels.mockCollectionController)
}

extension ICPNftDetails: Identifiable {
    public var id: String { index.description }
}

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
    private var isPresenting: Binding<Bool> { Binding(get: { presentingNft != nil }, set: {_ in }) }
    
    var body: some View {
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
                if let nfts = controller.nfts {
                    NftProperty(label: "Number of NFTs", value: String(nfts.count))
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(minimum: 170, maximum: .infinity)),
                            GridItem(.flexible(minimum: 170, maximum: .infinity))
                        ]) {
                            ForEach(nfts) { nft in
                                NftPreview(nft: nft).onTapGesture { presentingNft = nft }
                            }
                        }
                } else {
                    ProgressView()
                }
            }
            .safeAreaPadding()
        }
        .navigationTitle(controller.collection.name)
        .sheet(isPresented: isPresenting) {
            presentingNft = nil
        } content: {
            NftDetails(nft: presentingNft!)
        }
    }
}

#Preview {
    NftCollectionDetails(controller: PreviewModels.mockCollectionController)
}

extension ICPNftDetails: Identifiable {
    public var id: String { index.description }
}

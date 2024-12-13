//
//  AllNfts.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import DAB

struct AllNfts: View {
    @StateObject var controller: AppController
    
    @State private var searchString: String = ""
    @State private var searchStandard: ICPNftStandard?
    
    private var filteredCollections: Binding<[ICPNftCollection]?> { Binding.readOnly {
        guard var collections = controller.collections else { return nil }
        if let searchStandard = searchStandard {
            collections = collections.filter { $0.standard == searchStandard }
        }
        if !searchString.isEmpty {
            collections = collections.filter { $0.name.contains(searchString) }
        }
        return collections
    }}
    
    var body: some View {
        VStack {
            SearchBar(searchString: $searchString, standard: $searchStandard)
            ScrollView {
                Lazy2dGrid(items: filteredCollections, builder: {                    
                    NftCollectionPreview(collection: $0, service: controller.nftService)
                })
            }
        }
    }
}

#Preview {
    AllNfts(controller: PreviewModels.mockAppController)
}

extension ICPNftCollection: Identifiable {
    public var id: String { canister.string }
}

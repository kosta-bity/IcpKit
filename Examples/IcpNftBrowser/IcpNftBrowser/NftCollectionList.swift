//
//  NftCollectionList.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import DAB

struct NftCollectionList: View {
    @Binding var collections: [ICPNftCollection]?
    
    var body: some View {
        if let collections = collections {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 170, maximum: .infinity)),
                    GridItem(.flexible(minimum: 170, maximum: .infinity))
                ]) {
                ForEach(collections) { collection in
                    NftCollectionPreview(collection: collection)
                }
            }
            .padding()
            
        } else {
            Text("Loading...")
            ProgressView()
        }
    }
}

#Preview {
    NftCollectionList(collections: .constant(PreviewModels.fakeCollections))
}

extension ICPNftCollection: Identifiable {
    public var id: String { canister.string }
}

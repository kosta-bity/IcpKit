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
    let service: DABNftService
    
    var body: some View {
        ScrollView {
            Lazy2dGrid(items: $collections, builder: { NftCollectionPreview(collection: $0, service: service) })
        }
    }
}

#Preview {
    NftCollectionList(collections: .constant(PreviewModels.fakeCollections), service: PreviewModels.mockService)
}

extension ICPNftCollection: Identifiable {
    public var id: String { canister.string }
}

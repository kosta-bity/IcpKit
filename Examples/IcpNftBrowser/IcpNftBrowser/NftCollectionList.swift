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
        ScrollView {
            Lazy2dGrid(items: $collections, builder: NftCollectionPreview.init)
        }
    }
}

#Preview {
    NftCollectionList(collections: .constant(PreviewModels.fakeCollections))
}

extension ICPNftCollection: Identifiable {
    public var id: String { canister.string }
}

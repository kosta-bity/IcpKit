//
//  NftCollectionPreview.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import DAB

struct NftCollectionPreview: View {
    let collection: ICPNftCollection
    let service: DABNftService
    
    var body: some View {
        NavigationLink {
            NftCollectionDetails(controller: CollectionController(collection: collection, service: service))
        } label: {
            contents
        }
    }
    
    private var contents: some View {
        Card(
            image: collection.icon,
            title: collection.name,
            description: collection.description,
            tag: collection.standard.description
        )
    }
}

#Preview {
    return NftCollectionPreview(collection: PreviewModels.fakeCollections.first!, service: PreviewModels.mockService)
}

extension ICPNftStandard: Identifiable, CustomStringConvertible {
    public var id: ICPNftStandard { self }
    
    public var description: String {
        switch self {
        case .ext: return "ext"
        case .icrc7: return "icrc7"
        case .origynNft: return "origyn"
        case .dip721: return "dip721"
        case .dip721v2: return "dip721v2"
        case .icPunks: return "icPunks"
        case .departuresLabs: return "departureLabs"
        case .erc721: return "erc721"
        case .c3: return "c3"
        }
    }
}

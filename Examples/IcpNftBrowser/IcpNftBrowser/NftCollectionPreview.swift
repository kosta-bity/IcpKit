//
//  NftCollectionPreview.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import DAB

struct NftCollectionPreview: View {
    @State var collection: ICPNftCollection
    
    var body: some View {
        NavigationLink {
            NftCollectionDetails(controller: CollectionController(collection: collection))
        } label: {
            contents
        }
    }
    
    private var contents: some View {
        CardContainer {
            VStack {
                RemoteImage(url: collection.icon)
                Text(collection.name)
                    .bold()
                    .font(.title3)
                Text(collection.description)
                    .font(.caption)
                    .lineLimit(3)
            }
            .frame(height: 180)
            .tagged(collection.standard.description)
        }
    }
}

#Preview {
    return NftCollectionPreview(collection: PreviewModels.fakeCollections.first!)
}

extension ICPNftStandard: Identifiable, CustomStringConvertible {
    public var id: ICPNftStandard { self }
    
    public var description: String {
        switch self {
        case .ext: return "ext"
        case .icrc7: return "icrc7"
        case .origynNft: return "origyn"
        }
    }
}

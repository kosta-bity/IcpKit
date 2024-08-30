//
//  NftPreview.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import DAB

struct NftPreview: View {
    let nft: ICPNftDetails
    
    var body: some View {
        CardContainer {
            VStack {
                RemoteImage(url: nft.url)
                nft.name.map { Text($0)
                        .bold()
                        .font(.title3)
                }
            }
        }
    }
}

#Preview {
    NftPreview(nft: PreviewModels.mockNft)
}

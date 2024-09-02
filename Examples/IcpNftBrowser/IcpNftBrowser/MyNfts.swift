//
//  MyNfts.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import DAB

struct MyNfts: View {
    @StateObject var controller: AppController
    @State private var presentingNft: ICPNftDetails?
    @State private var principalString: String = ""
    
    var body: some View {
        SheetPresenter(presenting: $presentingNft, builder: NftDetails.init) {
            VStack {
                PrincipalInput(principalString: $principalString)
                    .onChange(of: principalString) { controller.fetchNfts(principalString) }
                ScrollView {
                    Lazy2dGrid(items: $controller.myNFTs) { nft in NftPreview(nft: nft).onTapGesture {
                        presentingNft = nft
                    }}
                }
            }
        }
    }
}

#Preview {
    MyNfts(controller: PreviewModels.mockAppController)
}

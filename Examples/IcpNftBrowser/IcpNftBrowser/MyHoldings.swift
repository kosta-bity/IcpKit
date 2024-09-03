//
//  MyHoldings.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import DAB

struct MyHoldings: View {
    @StateObject var controller: AppController
    @State private var presentingNft: ICPNftDetails?
    @State private var principalString: String = ""
    
    var body: some View {
        SheetPresenter(presenting: $presentingNft, builder: NftDetails.init) {
            VStack {
                PrincipalInput(principalString: $principalString)
                    .onChange(of: principalString) { controller.fetchNfts(principalString) }
                ScrollView {
                    VStack {
                        ForEach(controller.myTokens) { holding in
                            TokenBalance(holding: holding)
                        }
                        Lazy2dGrid(items: $controller.myNFTs) { nft in
                            NftPreview(nft: nft).onTapGesture { presentingNft = nft}
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MyHoldings(controller: PreviewModels.mockAppController)
}

extension TokenHolding: Identifiable {
    var id: String { token.canister.string }
}

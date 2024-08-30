//
//  ContentView.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import IcpKit
import DAB

struct ContentView: View {
    @StateObject var controller: AppController
    
    private enum Tab: Int {
        case allNfts
        case myNfts
    }
    @State private var presentingNft: ICPNftDetails?
    @State private var principalString: String = ""
    @State private var currentTab: Tab = .allNfts
    @State private var searchString: String = ""
    @State private var searchStandard: ICPNftStandard?
    
    private var filteredCollections: Binding<[ICPNftCollection]?> { Binding(
        get: {
            guard var collections = controller.collections else { return nil }
            if let searchStandard = searchStandard {
                collections = collections.filter { $0.standard == searchStandard }
            }
            if !searchString.isEmpty {
                collections = collections.filter { $0.name.contains(searchString) }
            }
            return collections
            
        },
        set: { _ in }
    )}
    
    var body: some View {
        NavigationView {
            VStack {
                tabs
                TabView(selection: $currentTab) {
                    allNfts.tag(Tab.allNfts)
                    myNfts.tag(Tab.myNfts)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .navigationTitle("Nft Collections")
            }
            .safeAreaPadding()
        }
    }
    
    private var tabs: some View {
        HStack {
            Spacer()
            Button("All NFTs") { currentTab = .allNfts }
            Spacer()
            Button("My NFTs") { currentTab = .myNfts }
            Spacer()
        }
    }
    
    private var allNfts: some View {
        VStack {
            SearchBar(searchString: $searchString, standard: $searchStandard)
            NftCollectionList(collections: filteredCollections)
                
        }
    }
    
    private var myNfts: some View {
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
    ContentView(controller: PreviewModels.mockAppController)
}

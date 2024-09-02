//
//  ContentView.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var controller: AppController
    
    private enum Tab { case allNfts, allTokens, myNfts }
    @State private var currentTab: Tab = .allNfts
    
    var body: some View {
        NavigationView {
            VStack {
                tabs
                TabView(selection: $currentTab) {
                    AllNfts(controller: controller).tag(Tab.allNfts)
                    AllTokens(controller: controller).tag(Tab.allTokens)
                    MyNfts(controller: controller).tag(Tab.myNfts)
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
            Button("All Tokens") { currentTab = .allTokens }
            Spacer()
            Button("My NFTs") { currentTab = .myNfts }
            Spacer()
        }
    }
}

#Preview {
    ContentView(controller: PreviewModels.mockAppController)
}

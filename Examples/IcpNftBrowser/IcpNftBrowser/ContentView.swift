//
//  ContentView.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import DAB

struct ContentView: View {
    @StateObject var controller: AppController
    @State var searchString: String = ""
    @State var searchStandard: ICPNftStandard?
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
                SearchBar(searchString: $searchString, standard: $searchStandard)
                ScrollView {
                    NftCollectionList(collections: filteredCollections)
                        .navigationTitle("Nft Collections")
                }
            }
        }
        .safeAreaPadding()
    }
}

#Preview {
    ContentView(controller: PreviewModels.mockAppController)
}

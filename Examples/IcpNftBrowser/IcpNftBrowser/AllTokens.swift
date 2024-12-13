//
//  AllTokens.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import SwiftUI
import DAB

struct AllTokens: View {
    @StateObject var controller: AppController
    
    @State private var presentingToken: ICPToken?
    @State private var searchString: String = ""
    @State private var searchStandard: ICPTokenStandard?
    
    private var filteredTokens: Binding<[ICPToken]?> { Binding.readOnly {
        guard var tokens = controller.tokens else { return nil }
        if let searchStandard = searchStandard {
            tokens = tokens.filter { $0.standard == searchStandard }
        }
        if !searchString.isEmpty {
            tokens = tokens.filter { $0.name.contains(searchString) }
        }
        return tokens
    }}
    
    var body: some View {
        SheetPresenter(presenting: $presentingToken) {
            TokenDetails(token: $0)
        } content: {
            VStack {
                SearchBar(searchString: $searchString, standard: $searchStandard)
                ScrollView {
                    Lazy2dGrid(items: filteredTokens, builder: { token in
                        TokenPreview(token: token)
                            .onTapGesture { presentingToken = token }
                    })
                }
            }
        }
    }
}

#Preview {
    AllTokens(controller: PreviewModels.mockAppController)
}

extension ICPToken: Identifiable {
    public var id: String { canister.string }
}

extension ICPTokenStandard: Identifiable {
    public var id: ICPTokenStandard { self }
}

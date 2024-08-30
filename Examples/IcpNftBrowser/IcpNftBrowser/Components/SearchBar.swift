//
//  SearchBar.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import DAB

struct SearchBar: View {
    @Binding var searchString: String
    @Binding var standard: ICPNftStandard?
    
    var body: some View {
        HStack {
            TextField("Search for NFTs", text: $searchString)
                .textFieldStyle(.roundedBorder)
            Menu {
                Button("All") { standard = nil }
                ForEach(ICPNftStandard.allCases) { standard in
                    Button(standard.description) { self.standard = standard }
                }
            } label: {
                Text(standard.map { "Only \($0.description)" } ?? "All")
            }
        }
    }
}

#Preview {
    SearchBar(searchString: .constant(""), standard: .constant(nil))
}

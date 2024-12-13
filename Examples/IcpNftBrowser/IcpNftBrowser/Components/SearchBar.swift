//
//  SearchBar.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI

struct SearchBar<T>: View where T: Identifiable & CaseIterable & CustomStringConvertible, T.AllCases.Element == T {
    @Binding var searchString: String
    @Binding var standard: T?
    
    var body: some View {
        HStack {
            TextField("Search for NFTs", text: $searchString)
                .textFieldStyle(.roundedBorder)
            Menu {
                Button("All") { standard = nil }
                ForEach(Array(T.allCases)) { standard in
                    Button(standard.description) { self.standard = standard }
                }
            } label: {
                Text(standard.map { "Only \($0.description)" } ?? "All")
            }
        }
    }
}


import DAB
#Preview {
    SearchBar(searchString: .constant(""), standard: .constant(ICPNftStandard.icrc7))
}

//
//  Lazy2dGrid.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI

struct Lazy2dGrid<Item: Identifiable, ItemContent: View>: View {
    @Binding var items: [Item]?
    let builder: (Item) -> ItemContent
    var body: some View {
        if let items = items {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 170, maximum: .infinity)),
                    GridItem(.flexible(minimum: 170, maximum: .infinity))
                ]) {
                    ForEach(items, content: builder)
                }
        } else {
            Text("Loading...")
            ProgressView()
        }
    }
}

#Preview {
    Lazy2dGrid(items: .constant([PreviewModel(id: "a"), PreviewModel(id: "b"), PreviewModel(id: "c")])) {
        Text($0.id)
    }
}

private struct PreviewModel: Identifiable {
    let id: String
}

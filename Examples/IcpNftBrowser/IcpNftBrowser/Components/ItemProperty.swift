//
//  ItemProperty.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI

struct ItemProperty: View {
    let label: String
    let value: String?
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            value.map {
                Text($0)
                    .bold()
            }
        }
        .padding(.horizontal)
        Divider()
    }
}

#Preview {
    ItemProperty(label: "ID", value: "aaaaa-aa")
}

//
//  CardContainer.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI

struct CardContainer<Content: View>: View {
    var content: () -> Content
    
    var body: some View {
        content()
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.tertiary)
            .cornerRadius(20) /// make the background rounded
            .overlay(         /// apply a rounded border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.black, lineWidth: 2)
            )
    }
}

#Preview {
    CardContainer { Text("Text") }
}

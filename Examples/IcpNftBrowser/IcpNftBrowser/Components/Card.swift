//
//  Card.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import SwiftUI

struct Card: View {
    let image: URL?
    let title: String?
    let description: String?
    let tag: String?
    
    var body: some View {
        VStack {
            RemoteImage(image)
                .frame(width: 100, height: 100)
                .scaledToFill()
                .clipShape(Circle())
            title.map { Text($0)
                .bold()
                .font(.title3)
            }
            description.map { Text($0)
                .font(.caption)
                .lineLimit(3)
            }
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .tagged(tag)
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
    Card(image: PreviewModels.mockUrl, title: "Title", description: "Some very long description.\nNew Lines possible", tag: "my little tag")
}

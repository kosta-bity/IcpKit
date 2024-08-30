//
//  RemoteImage.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI

struct RemoteImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            } else if phase.error != nil {
                Color.red // Indicates an error.
            } else {
                ProgressView()
            }
        }
        .frame(height: 100)
        .background(Color.gray)
        .clipShape(Circle())
    }
}

#Preview {
    RemoteImage(url: PreviewModels.mockUrl)
}

//
//  Tagged.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI

extension View {
    func tagged(_ string: String) -> some View {
        overlay(alignment: .topTrailing) {
            Text(string)
                .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                .font(.footnote)
                .foregroundStyle(.brown)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

//
//  SheetPresenter.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI

struct SheetPresenter<Presented, Content: View, PresentedView: View>: View {
    @Binding var presenting: Presented?
    let builder: (Presented) -> PresentedView
    let content: () -> Content
    private var isPresenting: Binding<Bool> { Binding.readOnly { presenting != nil } }
    
    var body: some View {
        content()
            .sheet(isPresented: isPresenting) {
                presenting = nil
            } content: {
                builder(presenting!)
            }
    }
}

#Preview {
    SheetPresenter(presenting: .constant("a"), builder: Text.init) {
        Text("Something")
    }
}

//
//  ContentView.swift
//  AppIcp
//
//  Created by Konstantinos Gaitanis on 20.11.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = try! IcpViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isBusy { ProgressView() }
                Text("Address:")
                Text(viewModel.account.address).fontWidth(.compressed)
            Divider()
                Text("Balance:")
            if let balance = viewModel.balance { Text(String(balance)) }
            else { Text("---") }
            Divider()
                Text("Transaction Block:")
                if let block = viewModel.transactionBlock { Text(String(block)) }
            Divider()
                Button("Query Balance") {
                    Task.detached { try await viewModel.queryBalance() }
                }.buttonStyle(.bordered)
                Button("Transfer") {
                    Task.detached { try await viewModel.send() }
                }.buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

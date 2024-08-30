//
//  AppController.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import Foundation
import DAB

class AppController: ObservableObject {
    @Published var collections: [ICPNftCollection]?
    
    private let nftService = DABNftService()
    
    init() { refreshCollections() }
    
    open func refreshCollections() {
        self.collections = nil
        Task {
            let collections = try await nftService.allCollections()
            print("Loaded \(collections.count) NFT Collections")
            DispatchQueue.main.async { self.collections = collections }
        }
    }
}

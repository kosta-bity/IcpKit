//
//  AppController.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import Foundation
import DAB
import IcpKit

class AppController: ObservableObject {
    @Published var collections: [ICPNftCollection]?
    @Published var myNFTs: [ICPNftDetails]? = []
    
    let nftService = DABNftService()
    
    init() { refreshCollections() }
    
    open func refreshCollections() {
        self.collections = nil
        Task {
            let collections = try await nftService.allCollections()
            DispatchQueue.main.async { self.collections = collections }
        }
    }
    
    func fetchNfts(_ principalString: String) {
        guard let principal = try? ICPPrincipal(principalString) else {
            print("invalid principal")
            myNFTs = []
            return
        }
        myNFTs = nil
        print("fetching holding for \(principal)")
        Task {
            let nfts = try await nftService.holdings(principal)
            DispatchQueue.main.async { self.myNFTs = nfts }
        }
    }
}

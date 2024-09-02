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
    @Published var tokens: [ICPToken]?
    @Published var myNFTs: [ICPNftDetails]? = []
    
    let nftService = DABNftService()
    let tokenService = DABTokenService()
    
    init() { refresh() }
    
    func refresh() {
        refreshCollections()
        refreshTokens()
    }
    
    open func refreshCollections() {
        self.collections = nil
        Task {
            let collections = try await nftService.allCollections()
            DispatchQueue.main.async { self.collections = collections }
        }
    }
    
    open func refreshTokens() {
        self.tokens = nil
        Task {
            let tokens = try await tokenService.allTokens()
            DispatchQueue.main.async { self.tokens = tokens }
        }
    }
    
    func fetchNfts(_ principalString: String) {
        guard let principal = try? ICPPrincipal(principalString) else {
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
    
    func fetchTokens(_ principal: String) {
        
    }
}

//
//  CollectionController.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import Foundation
import DAB

class CollectionController: ObservableObject {
    let collection: ICPNftCollection
    private lazy var actor: ICPNftActor = { DABNftService.actor(for: collection) }()
    
    @Published var nfts: [ICPNftDetails]?
    
    init(collection: ICPNftCollection) {
        self.collection = collection
        fetchNfts()
    }
    
    open func fetchNfts() {
        nfts = nil
        Task {
            let nfts = try await actor.allNfts()
            DispatchQueue.main.async {
                self.nfts = nfts
            }
        }
    }
}

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
    private let actor: ICPNftActor
    
    @Published var nfts: [ICPNftDetails]?
    
    init(collection: ICPNftCollection, service: DABNftService) {
        self.collection = collection
        self.actor = service.actor(for: collection)
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

//
//  DABNftService.swift
//
//
//  Created by Konstantinos Gaitanis on 28.08.24.
//

import Foundation
import IcpKit

public class DABNftService {
    private let service = try! DABNft.Service("ctqxp-yyaaa-aaaah-abbda-cai")
    
    public init() { }
    
    public func allCollections() async throws -> [ICPNftCollection] {
        let allCollections = try await service.get_all()
        return allCollections.compactMap(ICPNftCollection.init)
    }
    
    public static func `actor`(for nft: ICPNftDetails) -> any ICPNftActor {
        ICPNftActorFactory.actor(for: nft.standard, nft.canister)
    }
    
    public static func `actor`(for collection: ICPNftCollection) -> any ICPNftActor {
        ICPNftActorFactory.actor(for: collection.standard, collection.canister)
    }
    
    public func holdings(_ account: ICPPrincipal) async throws -> [ICPNftDetails] {
        let allCollections = try await allCollections()
        
        return try await withThrowingTaskGroup(of: [ICPNftDetails].self) { group in
            for collection in allCollections {
                group.addTask { try await self.holding(account, collection) }
            }
            var holding: [ICPNftDetails] = []
            for try await collectionHolding in group {
                holding.append(contentsOf: collectionHolding)
            }
            return holding
        }
    }
    
    private func holding(_ account: ICPPrincipal, _ collection: ICPNftCollection) async throws -> [ICPNftDetails] {
        let actor = ICPNftActorFactory.actor(for: collection.standard, collection.canister)
        do {
            let holding = try await actor.userTokens(account)
            return holding
        } catch (let error) {
            //print(error)
            return []
        }
    }
}

private extension ICPNftCollection {
    init?(_ nftCollection: DABNft.nft_canister) {
        guard let standard = ICPNftStandard(nftCollection.standard) else {
            return nil
        }
        self.standard = standard
        name = nftCollection.name
        description = nftCollection.description
        icon = URL(string: nftCollection.thumbnail)
        canister = nftCollection.principal_id
    }
}

private extension DABNft.nft_canister {
    var standard: String? {
        guard let standardValue = details.first(where: { $0._0 == "standard" })?._1,
              case .Text(let string) = standardValue else {
            return nil
        }
        return string
    }
}

private extension ICPNftStandard {
    init?(_ rawValue: String?) {
        switch rawValue?.lowercased() {
        case "ext": self = .ext
        case "icrc7": self = .icrc7
        case "nftorigyn": self = .origynNft
        default: return nil
        }
    }
}

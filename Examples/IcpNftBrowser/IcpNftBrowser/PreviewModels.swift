//
//  PreviewModels.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import Foundation
import DAB
import IcpKit

struct PreviewModels {
    private init() {}
    
    static let mockService = DABNftService()
    static let fakeCollections = (0..<10).map { buildFakeCollection("Fake Collection #\($0)") }
    static let mockAppController = MockAppController()
    static let mockCollectionController = MockCollectionController(collection: fakeCollections.first!, service: mockService)
    static let mockNft = buildFakeNftList(fakeCollections.first!).first!
    static let mockUrl: URL = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.nEHLDZOYs2khTgDdZfJ-hwAAAA%26pid%3DApi&f=1&ipt=758c269e9e78c6a643664a8716572a5ac72df26dfe102e0538fb480e794f4cb7&ipo=images"
    static let mockSvgUrl: URL = "https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.icp0.io/?type=thumbnail&tokenid=ngedt-bakor-uwiaa-aaaaa-cmaca-uaqca-aaaaa-a"
}

private func buildFakeCollection(_ name: String) -> ICPNftCollection {
    ICPNftCollection(
        standard: .origynNft,
        name: name,
        description: "A fake Collection that has some description that can contain lines that are extremely long but might be also short.\nMight even have new lines",
        icon: PreviewModels.mockUrl,
        canister: ICPPrincipal(Data(name.utf8))
    )
}

private func buildFakeNftList(_ collection: ICPNftCollection) -> [ICPNftDetails] {
    (0..<10).map { ICPNftDetails(
        standard: collection.standard,
        index: .number($0),
        name: "#\($0)",
        url: PreviewModels.mockUrl,
        metadata: nil,
        operator: nil,
        canister: collection.canister
    ) }
}

class MockAppController: AppController {
    override func refreshCollections() {
        self.collections = nil
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
            self.collections = PreviewModels.fakeCollections
        }
    }
    
    override func fetchNfts(_ principalString: String) {
        self.myNFTs = nil
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
            self.myNFTs = buildFakeNftList(PreviewModels.fakeCollections.first!)
        }
    }
}

class MockCollectionController: CollectionController {
    override func fetchNfts() {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
            self.nfts = buildFakeNftList(self.collection)
        }
    }
}

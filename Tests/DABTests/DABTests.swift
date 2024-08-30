//
//  DABTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 22.08.24.
//

import XCTest
import Candid
import IcpKit
import DAB

final class DABTests: XCTestCase {
    let nftService = DABNftService()
    
    func testAllCollections() async throws {
        let allCollections = try await nftService.allCollections()
        for collection in allCollections {
            if collection.canister.string == "io7gn-vyaaa-aaaak-qcbiq-cai" {
                print(collection)
            }
        }
    }
    
    func testAccountHolding() async throws {
        let holdings = try await nftService.holdings(kostaPrincipal)
        for nft in holdings {
            let details = try await nftService.actor(for: nft).nftDetails(nft.index)
            print(details)
        }
    }
    
    func testAllNfts() async throws {
        let allCollections = try await nftService.allCollections()
        let standard = ICPNftStandard.icrc7
        let collection = allCollections.first(where: { $0.canister.string == "auw3m-7yaaa-aaaal-qjf6q-cai" })!
        let actor = nftService.actor(for: collection)
        let nfts = try await actor.allNfts()
        for nft in nfts {
            //print(nft)
        }
        
        let standard2 = ICPNftStandard.ext
        let collection2 = allCollections.first(where: { $0.standard == standard2 })!
        let actor2 = nftService.actor(for: collection2)
        let nfts2 = try await actor2.allNfts()
        for nft2 in nfts2 {
            print(nft2)
        }
    }
    
//    func testCrack() async {
//        await crackCandidHash(3933747005)
//        //await crackCandidHash(1169352569) // icon
//        await crackCandidHash(2781795542)
//    }
}



let kostaPrincipal: ICPPrincipal = "42cjv-glyli-7erx2-uovp2-vcevd-f7lqz-2qtix-eijra-5r2hk-ysmgb-rqe"















private let letters = firstLetter
private let firstLetter = "abcdefghijklmnopqrstyuvwxyz_".split(separator: "").map(String.init)
private let maxLetters = 6

private func crackCandidHash(_ expected: Int) async {
    let found = await withTaskGroup(of: String?.self) { group in
        for letter in firstLetter {
            group.addTask { testAllChars(letter, expected, firstLetter) }
        }
        if let found = await group.first(where: { $0 != nil }) { return found }
        return nil
    }
    
    guard let found = found else {
        print("Nothing found for \(expected) with \(maxLetters) letters")
        return
    }
    print("FOUND IT!: \(found) = \(expected)")
}

private func testAllChars(_ word: String, _ expected: Int, _ letterSet: any Sequence<String>) -> String? {
    if CandidKey.candidHash(word) == expected { return word }
    guard word.count < maxLetters else { return nil }
    for letter in letters {
        let newWord = word + letter
        if let found = testAllChars(newWord, expected, letters) { return found }
    }
    return nil
}

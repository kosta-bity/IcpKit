//
//  DABTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 22.08.24.
//

import XCTest
import Candid
import IcpKit
@testable import DAB

final class DABTests: XCTestCase {
    let dab = try! DABNft.Service("ctqxp-yyaaa-aaaah-abbda-cai")
    
    func testGetAllNfts() async throws {
        let allNfts = try await dab.get_all()
        
        for nft in allNfts {
            print(nft)
        }
    }
    
    func testCrack() async {
        await crackCandidHash(3933747005)
        //await crackCandidHash(1169352569) // icon
        await crackCandidHash(2781795542)
    }
}



















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

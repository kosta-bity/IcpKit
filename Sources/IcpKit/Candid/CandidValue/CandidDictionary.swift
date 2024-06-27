//
//  CandidDictionary.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 27.04.23.
//

import Foundation

public struct CandidDictionary: ExpressibleByDictionaryLiteral, Equatable {
    public let candidSortedItems: [CandidKeyedItem]
    
    public var candidValues: [CandidValue] {
        candidSortedItems.map { $0.value }
    }
    
    public var candidTypes: [CandidKeyedItemType] {
        candidSortedItems.map(CandidKeyedItemType.init)
    }
    
    public init(_ dictionary: [String: CandidValue]) {
        candidSortedItems = dictionary
            .map(CandidKeyedItem.init)
            .sorted { $0.key.hash < $1.key.hash }  // sort by ascending keys
    }
    
    public init(_ hashedDictionary: [Int: CandidValue]) {
        candidSortedItems = hashedDictionary
            .map(CandidKeyedItem.init)
            .sorted { $0.key.hash < $1.key.hash }  // sort by ascending keys
    }
    
    public init(dictionaryLiteral elements: (String, CandidValue)...) {
        let dictionary = Dictionary(uniqueKeysWithValues: elements)
        self.init(dictionary)
    }
    
    public subscript (_ hashedKey: Int) -> CandidValue? {
        candidSortedItems.first { $0.key.hash == hashedKey }?.value
    }
    
    public subscript (_ key: String) -> CandidValue? {
        let hashedKey = CandidContainerKey.hash(key)
        return self[hashedKey]
    }
}

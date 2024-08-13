//
//  CandidDictionary.swift
//
//  Created by Konstantinos Gaitanis on 27.04.23.
//

import Foundation

public struct CandidRecord: ExpressibleByDictionaryLiteral, Equatable, Codable {
    public let candidSortedItems: [CandidKeyedValue]
    
    public var candidValues: [CandidValue] {
        candidSortedItems.map { $0.value }
    }
    
    public var candidTypes: [CandidKeyedType] {
        candidSortedItems.map(CandidKeyedType.init)
    }
    
    public init(_ dictionary: [String: CandidValue]) {
        candidSortedItems = dictionary
            .map(CandidKeyedValue.init)
            .sorted()  // sort by ascending keys
    }
    
    public init(_ hashedDictionary: [Int: CandidValue]) {
        candidSortedItems = hashedDictionary
            .map(CandidKeyedValue.init)
            .sorted()  // sort by ascending keys
    }
    
    public init(_ unnamedItems: any Sequence<CandidValue>) {
        var index = 0
        candidSortedItems = unnamedItems
            .map {
                let keyedItem = CandidKeyedValue(index, $0)
                index += 1
                return keyedItem
            }
            .sorted()
    }
    
    public init(_ keyedItems: any Sequence<CandidKeyedValue>) {
        candidSortedItems = keyedItems.sorted()  // sort by ascending keys
    }
    
    public init(dictionaryLiteral elements: (String, CandidValue)...) {
        let dictionary = Dictionary(uniqueKeysWithValues: elements)
        self.init(dictionary)
    }
    
    public subscript (_ hashedKey: Int) -> CandidValue? {
        candidSortedItems.first { $0.key.intValue == hashedKey }?.value
    }
    
    public subscript (_ key: String) -> CandidValue? {
        let hashedKey = CandidKey.candidHash(key)
        return self[hashedKey]
    }
}

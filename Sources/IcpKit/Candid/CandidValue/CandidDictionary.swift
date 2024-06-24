//
//  CandidDictionary.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 27.04.23.
//

import Foundation

public struct CandidDictionary: ExpressibleByDictionaryLiteral, Equatable {
    public let candidSortedItems: [CandidDictionaryItem]
    
    public var candidValues: [CandidValue] {
        candidSortedItems.map { $0.value }
    }
    
    public var candidTypes: [CandidDictionaryItemType] {
        candidSortedItems.map(CandidDictionaryItemType.init)
    }
    
    public init(_ dictionary: [String: CandidValue]) {
        candidSortedItems = dictionary
            .map(CandidDictionaryItem.init)
            .sorted { $0.key.hash < $1.key.hash }  // sort by ascending keys
    }
    
    public init(_ hashedDictionary: [Int: CandidValue]) {
        candidSortedItems = hashedDictionary
            .map(CandidDictionaryItem.init)
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
        let hashedKey = CandidDictionaryKey.hash(key)
        return self[hashedKey]
    }
}

public struct CandidDictionaryItem: Equatable {
    public let key: CandidDictionaryKey
    public let value: CandidValue
    
    public init(_ hashedKey: Int, _ value: CandidValue) {
        key = CandidDictionaryKey(hashedKey)
        self.value = value
    }
    
    public init(_ key: String, _ value: CandidValue) {
        self.key = CandidDictionaryKey(key)
        self.value = value
    }
}

public struct CandidDictionaryItemType: Equatable {
    public let key: CandidDictionaryKey
    public let type: CandidType
    
    public init(hashedKey: Int, type: CandidType) {
        key = CandidDictionaryKey(hashedKey)
        self.type = type
    }
    
    public init(_ item: CandidDictionaryItem) {
        key = item.key
        self.type = item.value.candidType
    }
    
    public init(_ key: String, _ type: CandidType) {
        self.key = CandidDictionaryKey(key)
        self.type = type
    }
}

public struct CandidDictionaryKey: Equatable, Hashable {
    public let hash: Int
    public let string: String?
    
    public init(_ hashedKey: Int) {
        self.hash = hashedKey
        self.string = nil
    }
    
    public init(_ key: String) {
        self.hash = Self.hash(key)
        self.string = key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public static func ==(lhs: CandidDictionaryKey, rhs: CandidDictionaryKey) -> Bool {
        lhs.hash == rhs.hash
    }
    
    /// https://github.com/dfinity/candid/blob/master/spec/Candid.md
    /// hash(id) = ( Sum(i=0..k) utf8(id)[i] * 223^(k-i) ) mod 2^32 where k = |utf8(id)|-1
    public static func hash(_ key: String) -> Int {
        let data = Data(key.utf8)
        return data.reduce(0) { ($0 * 223 + Int($1)) & 0x00000000ffffffff }
    }
}

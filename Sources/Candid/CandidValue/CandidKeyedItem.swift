//
//  CandidKeyedItem.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation

public struct CandidKeyedItem: Equatable, Comparable, Codable {
    public let key: CandidContainerKey
    public let value: CandidValue
    
    public init(_ hashedKey: Int, _ value: CandidValue = .null) {
        self.init(CandidContainerKey(hashedKey), value)
    }
    
    public init(_ key: String, _ value: CandidValue = .null) {
        self.init(CandidContainerKey(key), value)
    }
    
    public init(_ key: CandidContainerKey, _ value: CandidValue = .null) {
        self.key = key
        self.value = value
    }
    
    public static func < (lhs: CandidKeyedItem, rhs: CandidKeyedItem) -> Bool {
        lhs.key < rhs.key
    }
}

public struct CandidKeyedItemType: Equatable, Comparable, Codable {
    public let key: CandidContainerKey
    public let type: CandidType
    
    public init(_ key: CandidContainerKey, _ type: CandidType) {
        self.key = key
        self.type = type
    }
    
    public init(hashedKey: Int, type: CandidType) {
        key = CandidContainerKey(hashedKey)
        self.type = type
    }
    
    public init(_ item: CandidKeyedItem) {
        key = item.key
        self.type = item.value.candidType
    }
    
    public init(_ key: String, _ type: CandidType) {
        self.key = CandidContainerKey(key)
        self.type = type
    }
    
    public static func < (lhs: CandidKeyedItemType, rhs: CandidKeyedItemType) -> Bool {
        lhs.key < rhs.key
    }
}

public protocol CandidContainerKeyProtocol: Equatable, Hashable, Comparable, Codable {
    var hash: Int { get }
    var string: String? { get }
}

public struct CandidContainerKey: CandidContainerKeyProtocol {
    public let hash: Int
    public let string: String?
    
    public var hasString: Bool { string != nil }
    
    public init(_ hashedKey: Int) {
        self.hash = hashedKey
        self.string = nil
    }
    
    public init(_ key: String) {
        self.hash = Self.candidHash(key)
        self.string = key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public static func ==(lhs: CandidContainerKey, rhs: CandidContainerKey) -> Bool {
        lhs.hash == rhs.hash
    }
    
    public static func < (lhs: CandidContainerKey, rhs: CandidContainerKey) -> Bool {
        lhs.hash < rhs.hash
    }
    
    /// https://github.com/dfinity/candid/blob/master/spec/Candid.md
    /// hash(id) = ( Sum(i=0..k) utf8(id)[i] * 223^(k-i) ) mod 2^32 where k = |utf8(id)| -1
    public static func candidHash(_ key: String) -> Int {
        let data = Data(key.utf8)
        return data.reduce(0) { ($0 * 223 + Int($1)) & 0x00000000ffffffff }
    }
}

//
//  CandidKeyedItem.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation

public struct CandidKeyedValue: Equatable, Comparable, Codable {
    public let key: CandidKey
    public let value: CandidValue
    
    public init(_ key: Int, _ value: CandidValue = .null) {
        self.init(CandidKey(key), value)
    }
    
    public init(_ key: String, _ value: CandidValue = .null) {
        self.init(CandidKey(key), value)
    }
    
    public init(_ key: CandidKey, _ value: CandidValue = .null) {
        self.key = key
        self.value = value
    }
    
    public static func < (lhs: CandidKeyedValue, rhs: CandidKeyedValue) -> Bool {
        lhs.key < rhs.key
    }
}

public struct CandidKeyedType: Equatable, Comparable, Codable {
    public let key: CandidKey
    public let type: CandidType
    
    public init(_ key: CandidKey, _ type: CandidType) {
        self.key = key
        self.type = type
    }
    
    public init(_ key: Int, _ type: CandidType) {
        self.key = CandidKey(key)
        self.type = type
    }
    
    public init(_ value: CandidKeyedValue) {
        key = value.key
        self.type = value.value.candidType
    }
    
    public init(_ key: String, _ type: CandidType) {
        self.key = CandidKey(key)
        self.type = type
    }
    
    public static func < (lhs: CandidKeyedType, rhs: CandidKeyedType) -> Bool {
        lhs.key < rhs.key
    }
}

public protocol CandidKeyProtocol: Equatable, Hashable, Comparable, Codable {
    var intValue: Int { get }
    var stringValue: String? { get }
}

public struct CandidKey: CandidKeyProtocol {
    public let intValue: Int
    public let stringValue: String?
    
    public var hasString: Bool { stringValue != nil }
    
    public init(_ intValue: Int) {
        self.intValue = intValue
        self.stringValue = nil
    }
    
    public init(_ stringValue: String) {
        self.intValue = Self.candidHash(stringValue)
        self.stringValue = stringValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(intValue)
    }
    
    public static func ==(lhs: CandidKey, rhs: CandidKey) -> Bool {
        lhs.intValue == rhs.intValue
    }
    
    public static func < (lhs: CandidKey, rhs: CandidKey) -> Bool {
        lhs.intValue < rhs.intValue
    }
    
    /// https://github.com/dfinity/candid/blob/master/spec/Candid.md
    /// hash(id) = ( Sum(i=0..k) utf8(id)[i] * 223^(k-i) ) mod 2^32 where k = |utf8(id)| -1
    public static func candidHash(_ key: String) -> Int {
        let data = Data(key.utf8)
        return data.reduce(0) { ($0 * 223 + Int($1)) & 0x00000000ffffffff }
    }
}

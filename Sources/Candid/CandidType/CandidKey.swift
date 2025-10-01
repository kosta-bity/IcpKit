//
//  CandidKey.swift
//
//
//  Created by Konstantinos Gaitanis on 07.08.24.
//

import Foundation

public protocol CandidKeyProtocol: Equatable, Hashable, Comparable, Codable, Sendable {
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

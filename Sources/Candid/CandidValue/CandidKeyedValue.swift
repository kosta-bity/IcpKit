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

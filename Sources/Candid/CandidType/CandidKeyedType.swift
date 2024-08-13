//
//  CandidKeyedType.swift
//
//
//  Created by Konstantinos Gaitanis on 07.08.24.
//

import Foundation

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

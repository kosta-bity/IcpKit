//
//  CandidVariant.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 08.05.23.
//

import Foundation

public enum CandidVariantError: Error {
    case valueNotPartOfTypes
}

public struct CandidVariant: Equatable {
    public let candidTypes: [CandidKeyedItemType]
    public let value: CandidValue
    public let valueIndex: UInt
    public var key: CandidContainerKey { candidTypes[Int(valueIndex)].key }
    
    public init(candidTypes: [CandidKeyedItemType], value: CandidValue, valueIndex: UInt) {
        self.candidTypes = candidTypes.sorted()
        self.value = value
        self.valueIndex = valueIndex
    }
    
    public init(candidTypes: [(String, CandidType)], value: (String, CandidValue)) throws {
        guard let index = candidTypes.firstIndex(where: { $0.0 == value.0 }) else {
            throw CandidVariantError.valueNotPartOfTypes
        }
        self.valueIndex = UInt(index)
        self.candidTypes = candidTypes.map(CandidKeyedItemType.init).sorted()
        self.value = value.1
    }
    
    public subscript (_ key: String) -> CandidValue? {
        self[CandidContainerKey.hash(key)]
    }
    
    public subscript (_ key: Int) -> CandidValue? {
        guard self.key.hash == key else { return nil }
        return value
    }
}


//
//  CandidKeyedTypes.swift
//  
//
//  Created by Konstantinos Gaitanis on 07.08.24.
//

import Foundation

public struct CandidKeyedTypes: ExpressibleByArrayLiteral, Equatable, Sequence, Codable, Sendable {
    public typealias Element = CandidKeyedType
    public typealias Iterator = Array<CandidKeyedType>.Iterator
    public let items: [CandidKeyedType]
    
    public init(arrayLiteral elements: CandidKeyedType...) {
        items = elements.sorted()
    }
    
    public init(_ items: any Sequence<CandidType>) {
        var index = 0
        self.items = items
            .map {
                let keyedItem = CandidKeyedType(index, $0)
                index += 1
                return keyedItem
            }
            .sorted()
    }
    
    public init(_ items: any Sequence<CandidKeyedType>) {
        self.items = items.sorted()
    }
    
    public subscript (_ keyHash: Int) -> CandidKeyedType? {
        return items.first { $0.key.intValue == keyHash }
    }
    
    public subscript (_ key: String) -> CandidKeyedType? {
        return items.first { $0.key.stringValue == key }
    }
    
    public subscript (_ key: CandidKey) -> CandidKeyedType? {
        return items.first { $0.key == key }
    }
    
    public func makeIterator() -> Array<CandidKeyedType>.Iterator { items.makeIterator() }
    public var count: Int { items.count }
}

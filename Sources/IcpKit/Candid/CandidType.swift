//
//  CandidType.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 27.04.23.
//

import Foundation
import OrderedCollections

/// Contains the necessary data to fully describe the Candid Value
/// and its contained child values
public indirect enum CandidType: Equatable, Encodable {
    case null
    case bool
    case natural
    case integer
    case natural8
    case natural16
    case natural32
    case natural64
    case integer8
    case integer16
    case integer32
    case integer64
    case float32
    case float64
    case text
    case reserved
    case empty
    case option(CandidType)
    case vector(CandidType)
    case record(CandidKeyedTypes)
    case variant(CandidKeyedTypes)
    case function(CandidFunctionSignature)
    case service(CandidServiceSignature)
    case principal
    case named(String)
}

public struct CandidKeyedTypes: ExpressibleByArrayLiteral, Equatable, Sequence, Encodable {
    public typealias Element = CandidKeyedItemType
    public typealias Iterator = Array<CandidKeyedItemType>.Iterator
    public let items: [CandidKeyedItemType]
    
    public init(arrayLiteral elements: CandidKeyedItemType...) {
        items = elements.sorted()
    }
    
    public init(_ items: any Sequence<CandidType>) {
        var index = 0
        self.items = items
            .map {
                let keyedItem = CandidKeyedItemType(hashedKey: index, type: $0)
                index += 1
                return keyedItem
            }
            .sorted()
    }
    
    public init(_ items: any Sequence<CandidKeyedItemType>) {
        self.items = items.sorted()
    }
    
    public subscript (_ keyHash: Int) -> CandidKeyedItemType? {
        return items.first { $0.key.hash == keyHash }
    }
    
    public subscript (_ key: String) -> CandidKeyedItemType? {
        return items.first { $0.key.string == key }
    }
    
    public subscript (_ key: CandidContainerKey) -> CandidKeyedItemType? {
        return items.first { $0.key == key }
    }
    
    public func makeIterator() -> Array<CandidKeyedItemType>.Iterator { items.makeIterator() }
    public var count: Int { items.count }
}

extension CandidType {
    var primitiveType: CandidPrimitiveType {
        switch self {
        case .null: return .null
        case .bool: return .bool
        case .natural: return .natural
        case .integer: return .integer
        case .natural8: return .natural8
        case .natural16: return .natural16
        case .natural32: return .natural32
        case .natural64: return .natural64
        case .integer8: return .integer8
        case .integer16: return .integer16
        case .integer32: return .integer32
        case .integer64: return .integer64
        case .float32: return .float32
        case .float64: return .float64
        case .text: return .text
        case .reserved: return .reserved
        case .empty: return .empty
        case .option: return .option
        case .vector: return .vector
        case .record: return .record
        case .variant: return .variant
        case .function: return .function
        case .service: return .service
        case .principal: return .principal
        case .named: fatalError("should never be called")
        }
    }
}

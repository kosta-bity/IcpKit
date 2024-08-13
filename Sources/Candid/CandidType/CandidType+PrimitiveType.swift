//
//  CandidType+PrimitiveType.swift
//  
//
//  Created by Konstantinos Gaitanis on 07.08.24.
//

import Foundation

public extension CandidType {
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

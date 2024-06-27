//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

extension CandidType {
    var syntax: String {
        switch self {
        case .primitive(let type): return type.syntax
        case .container(let containerType, let containedType): return "\(containerType.syntax) \(containedType.syntax)"
        case .keyedContainer(let containerType, let keyedItems):
            if keyedItems.isEmpty { return "\(containerType.syntax) {}" }
            return """
\(containerType.syntax) {

}
"""
        case .function(_):
            return "\(CandidPrimitiveType.function.syntax) () -> ()"
        case .service(_):
            return "\(CandidPrimitiveType.service.syntax): {}"
        }
    }
}

extension CandidPrimitiveType {
    var syntax: String {
        switch self {
        case .null: return "null"
        case .bool: return "bool"
        case .natural: return "nat"
        case .integer: return "int"
        case .natural8: return "nat8"
        case .natural16: return "nat16"
        case .natural32: return "nat32"
        case .natural64: return "nat64"
        case .integer8: return "int8"
        case .integer16: return "int16"
        case .integer32: return "int32"
        case .integer64: return "int64"
        case .float32: return "float32"
        case .float64: return "float64"
        case .text: return "text"
        case .reserved: return "reserved"
        case .empty: return "empty"
        case .option: return "opt"
        case .vector: return "vec"
        case .record: return "record"
        case .variant: return "variant"
        case .function: return "func"
        case .principal: return "principal"
        case .service: return "service"
        }
    }
}

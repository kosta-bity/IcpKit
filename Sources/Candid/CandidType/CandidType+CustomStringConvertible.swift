//
//  CandidType+CustomStringConvertible.swift
//  
//
//  Created by Konstantinos Gaitanis on 07.08.24.
//

import Foundation

extension CandidType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .variant(let containedTypes): return "variant { \(containedTypes) }"
        case .record(let containedTypes): return "record { \(containedTypes) }"
        case .option(let containedType): return "opt \(containedType)"
        case .vector(let containedType): return "vec \(containedType)"
        case .function(let signature): return "function \(signature)"
        case .service(let signature): return "service: { \(signature) }"
        case .named(let name): return name
        default: return primitiveType.description
        }
    }
}

extension CandidPrimitiveType: CustomStringConvertible {
    public var description: String {
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
        case .function: return "function"
        case .principal: return "principal"
        case .service: return "service"
        }
    }
}

extension CandidKeyedTypes: CustomStringConvertible {
    public var description: String {
        items.map { "\($0)" }.joined(separator: "; ")
    }
}

extension CandidFunctionSignature: CustomStringConvertible {
    public var description: String {
        let inputs = arguments.map { "\($0)" }.joined(separator: "; ")
        let outputs = results.map { "\($0)" }.joined(separator: "; ")
        let annotations = [
            annotations.query ? "query" : "",
            annotations.oneWay ? "oneway" : "",
            annotations.compositeQuery ? "composite_query" : "",
        ].joined(separator: " ")
        return "(\(inputs)) -> (\(outputs)) \(annotations)"
    }
}

extension CandidServiceSignature: CustomStringConvertible {
    public var description: String {
        methods.map { "\($0.name): \($0.functionSignature)" }.joined(separator: ",\n")
    }
}

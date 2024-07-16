//
//  CandidValue+CustomStringConvertible.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 16.05.23.
//

import Foundation

extension CandidValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null: return "null"
        case .bool(let bool): return "bool(\(bool))"
        case .natural(let bigUInt): return "natural(\(bigUInt))"
        case .integer(let bigInt): return "integer(\(bigInt))"
        case .natural8(let uInt8): return "natural8(\(uInt8))"
        case .natural16(let uInt16): return "natural16(\(uInt16))"
        case .natural32(let uInt32): return "natural32(\(uInt32))"
        case .natural64(let uInt64): return "natural64(\(uInt64))"
        case .integer8(let int8): return "integer8(\(int8))"
        case .integer16(let int16): return "integer16(\(int16))"
        case .integer32(let int32): return "integer32(\(int32))"
        case .integer64(let int64): return "integer64(\(int64))"
        case .float32(let float): return "float32(\(float))"
        case .float64(let double): return "float64(\(double))"
        case .text(let string): return "text(\(string))"
        case .reserved: return "reserved"
        case .empty: return "empty"
        case .option(let option): return "option(\(option))"
        case .vector(let vector): return "vector(\(vector))"
        case .blob(let data): return "blob(\(data.hex)"
        case .record(let dictionary): return "record(\(dictionary))"
        case .variant(let variant): return "variant(\(variant))"
        case .function(let function): return "function(\(function))"
        case .principal(let principal): return "principal \(principal?.string ?? "")"
        case .service: return "service()"
        }
    }
}

extension CandidOption: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none(let type): return "none(\(type))"
        case .some(let value): return "\(value)"
        }
    }
}

extension CandidVector: CustomStringConvertible {
    public var description: String {
        let itemsString = values.map { "\($0)" }.joined(separator: ", ")
        return "[\(itemsString)]"
    }
}

extension CandidDictionary: CustomStringConvertible {
    public var description: String {
        let itemsString = candidSortedItems.map { "\($0.key.hash): \($0.value)" }.joined(separator: ",\n\t")
        return "[\n\t\(itemsString)]"
    }
}

extension CandidKeyedItemType: CustomStringConvertible {
    public var description: String {
        return "\(key.hash): \(type)"
    }
}

extension CandidVariant: CustomStringConvertible {
    public var description: String {
        let typesString = candidTypes.map { "\($0.key.hash)" }.joined(separator: ", ")
        return "[\(typesString)],\nvalue: (\(valueIndex)) \(value)"
    }
}

extension CandidFunction: CustomStringConvertible {
    public var description: String {
        let inputs = signature.arguments.map { "\($0)" }.joined(separator: ", ")
        let outputs = signature.results.map { "\($0)" }.joined(separator: ", ")
        let annotations = [
            signature.annotations.query ? "Q" : "",
            signature.annotations.oneWay ? "OW" : "",
        ].joined(separator: "|")
        let methodString: String
        if let method = method {
            methodString = "\(method.principal.string).\(method.name)"
        } else {
            methodString = "none"
        }
        return "\(annotations) (\(inputs)) -> (\(outputs)) method: \(methodString)"
    }
}

extension CandidType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .variant(let containedTypes), .record(let containedTypes):
            let types = containedTypes.map { "\($0.key.string ?? String($0.key.hash)): \($0.type.description)" }
            return "\(primitiveType.description) { \(types) }"
        case .option(let containedType): return "opt \(containedType.description)"
     case .vector(let containedType): return "vec \(containedType.description)"
        case .function(let signature):
            let inputs = signature.arguments.map { "\($0)" }.joined(separator: ", ")
            let outputs = signature.results.map { "\($0)" }.joined(separator: ", ")
            let annotations = [
                signature.annotations.query ? "Q" : "",
                signature.annotations.oneWay ? "OW" : "",
            ].joined(separator: "|")
            return "function( \(annotations) (\(inputs)) -> (\(outputs)))"
        case .service(let signature):
            let methodsString = signature.methods.map { "\($0.name): \($0.functionSignature)" }.joined(separator: ",\n")
            return "service(methods: [\(methodsString)])"
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

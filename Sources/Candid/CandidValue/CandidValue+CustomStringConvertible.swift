//
//  CandidValue+CustomStringConvertible.swift
//
//  Created by Konstantinos Gaitanis on 16.05.23.
//

import Foundation

extension CandidValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null: return "null"
        case .bool(let bool): return "\(bool)"
        case .natural(let bigUInt): return "\(bigUInt)"
        case .integer(let bigInt): return "\(bigInt)"
        case .natural8(let uInt8): return "\(uInt8) : nat8"
        case .natural16(let uInt16): return "\(uInt16) : nat16"
        case .natural32(let uInt32): return "\(uInt32) : nat32"
        case .natural64(let uInt64): return "\(uInt64) : nat64"
        case .integer8(let int8): return "\(int8) : int8"
        case .integer16(let int16): return "\(int16) : int16"
        case .integer32(let int32): return "\(int32) : int32"
        case .integer64(let int64): return "\(int64) : int64"
        case .float32(let float): return "\(float) : float32"
        case .float64(let double): return "\(double)"
        case .text(let string): return "\(string)"
        case .reserved: return "reserved"
        case .empty: return "empty"
        case .option(let option): return "opt \(option)"
        case .vector(let vector): return "vec \(vector)"
        case .blob(let data): return "blob \"\(data.hex)\""
        case .record(let dictionary): return "record {\(dictionary)}"
        case .variant(let variant): return "variant {\(variant)}"
        case .function(let function): return "function \(function)"
        case .principal(let principal): return "principal \"\(principal?.string ?? "")\""
        case .service(let signature): return "service: \"\(signature.principal?.string ?? "")\""
        }
    }
}

extension CandidOption: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none(let type): return "null: \(type)"
        case .some(let value): return "\(value)"
        }
    }
}

extension CandidVector: CustomStringConvertible {
    public var description: String {
        
        let itemsString = values.map { $0.description }.joined(separator: "; ")
        return "\(containedType) {\(itemsString)}"
    }
}

extension CandidRecord: CustomStringConvertible {
    public var description: String {
        let itemsString = candidSortedItems.map { $0.description }.joined(separator: ";\n\t")
        return "\n\t\(itemsString)"
    }
}

extension CandidKeyedType: CustomStringConvertible {
    public var description: String {
        return "\(key.stringValue ?? String(key.intValue)): \(type)"
    }
}

extension CandidKeyedValue: CustomStringConvertible {
    public var description: String {
        return "\(key.stringValue ?? String(key.intValue)) = \(value)"
    }
}

extension CandidVariant: CustomStringConvertible {
    public var description: String {
        return "\(key.stringValue ?? String(key.intValue)): \(value)"
    }
}

extension CandidFunction: CustomStringConvertible {
    public var description: String {
        let methodString: String
        if let method = method {
            methodString = "\(method.principal.string).\(method.name) "
        } else {
            methodString = ""
        }
        return "\(methodString)\(signature)"
    }
}



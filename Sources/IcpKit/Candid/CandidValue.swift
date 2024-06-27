//
//  CandidSerialiser.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 26.04.23.
//

import Foundation
import BigInt

/// https://github.com/dfinity/candid/blob/master/spec/Candid.md
public indirect enum CandidValue: Equatable {
    case null
    case bool(Bool)
    case natural(BigUInt)
    case integer(BigInt)
    case natural8(UInt8)
    case natural16(UInt16)
    case natural32(UInt32)
    case natural64(UInt64)
    case integer8(Int8)
    case integer16(Int16)
    case integer32(Int32)
    case integer64(Int64)
    case float32(Float)
    case float64(Double)
    case text(String)
    case blob(Data)
    case reserved
    case empty
    case option(CandidOption)
    case vector(CandidVector)
    case record(CandidDictionary)
    case variant(CandidVariant)
    case function(CandidFunction)
    case principal(CandidPrincipal?)
    case service(CandidService)
}

// MARK: CandidType
public extension CandidValue {
    var candidType: CandidType {
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
        case .blob: return .vector(.natural8)
        case .option(let option): return .option(option.containedType)
        case .vector(let vector): return .vector(vector.containedType)
        case .record(let dictionary): return .record(dictionary.candidTypes)
        case .variant(let variant): return .variant(variant.candidTypes)
        case .function(let function): return .function(function.signature)
        case .principal: return .principal
        case .service(let service): return .service(service.methods)
        }
    }
}

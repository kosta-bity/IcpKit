//
//  CandidType.swift
//
//  Created by Konstantinos Gaitanis on 27.04.23.
//

import Foundation
import OrderedCollections

/// Contains the necessary data to fully describe the Candid Value
/// and its contained child values
public indirect enum CandidType: Equatable, Codable {
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

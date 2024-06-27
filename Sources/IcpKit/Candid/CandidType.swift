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
public indirect enum CandidType: Equatable {
    case primitive(CandidPrimitiveType)
    case container(CandidPrimitiveType, CandidType)
    case keyedContainer(CandidPrimitiveType, [CandidKeyedItemType])
    case function(CandidFunctionSignature)
    case service(CandidServiceSignature)
    case named(String)
}

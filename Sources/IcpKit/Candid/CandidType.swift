//
//  CandidType.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 27.04.23.
//

import Foundation
import OrderedCollections

public indirect enum CandidType: Equatable {
    case primitive(CandidPrimitiveType)
    case container(CandidPrimitiveType, CandidType)
    case keyedContainer(CandidPrimitiveType, [CandidDictionaryItemType])
    case function(CandidFunctionSignature)
    //case service([CandidService.Method])
}

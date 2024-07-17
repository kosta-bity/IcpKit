//
//  GeneratedCandidType.swift
//
//
//  Created by Konstantinos Gaitanis on 16.07.24.
//

import Foundation

public protocol GeneratedCandidType {
    func candidValue() throws -> CandidValue
    
}

extension GeneratedCandidType {
    func candidType() throws -> CandidType { try candidValue().candidType }
}

//
//  GeneratedCandidType.swift
//
//
//  Created by Konstantinos Gaitanis on 16.07.24.
//

import Foundation

public protocol GeneratedCandidType: Codable {}

extension GeneratedCandidType {
    func candidType() throws -> CandidType { try candidValue().candidType }
    
    func candidValue() throws -> CandidValue {
        try CandidEncoder().encode(self)
    }
    
    static func initFromCandidValue(_ value: CandidValue) throws -> Self {
        try CandidDecoder().decode(value)
    }
}

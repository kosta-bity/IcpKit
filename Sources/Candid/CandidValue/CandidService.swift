//
//  CandidService.swift
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public struct CandidService: Equatable, Codable {
    public let principal: CandidPrincipal?
    public let signature: CandidServiceSignature
    
    public init(principal: CandidPrincipal?, signature: CandidServiceSignature) {
        self.principal = principal
        self.signature = signature
    }
}

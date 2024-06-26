//
//  CandidService.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public struct CandidService: Equatable {
    public let methods: [Method]
    public let principalId: CandidPrincipal?
    
    public struct Method: Equatable {
        public let name: String
        public let functionSignature: CandidFunctionSignature
    }
}

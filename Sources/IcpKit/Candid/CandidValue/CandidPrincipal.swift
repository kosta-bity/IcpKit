//
//  CandidPrincipal.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

public struct CandidPrincipal: Equatable {
    public let bytes: Data
    public let string: String
    
    public init(_ string: String) throws {
        self.string = string
        self.bytes = try ICPCryptography.decodeCanonicalText(string)
    }
    
    public init(_ bytes: Data) {
        self.bytes = bytes
        self.string = ICPCryptography.encodeCanonicalText(bytes)
    }
}

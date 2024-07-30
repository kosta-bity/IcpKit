//
//  CandidPrincipal.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation
import Utils

public struct CandidPrincipal: Equatable, Codable {
    public let bytes: Data
    public let string: String
    
    public init(_ string: String) throws {
        self.string = string
        self.bytes = try CanonicalText.decode(string)
    }
    
    public init(_ bytes: Data) {
        self.bytes = bytes
        self.string = CanonicalText.encode(bytes)
    }
}

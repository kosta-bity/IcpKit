//
//  CandidPrincipal.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

/// from https://internetcomputer.org/docs/current/references/ic-interface-spec/#principal
public struct CandidPrincipal: Equatable, Codable, ExpressibleByStringLiteral, CustomStringConvertible, Sendable {
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
    
    public static func isValid(_ string: String) -> Bool {
        guard let _ = try? CanonicalText.decode(string) else { return false }
        return true
    }
}

public extension CandidPrincipal {
    var description: String { string }
    
    init(stringLiteral value: String) {
        try! self.init(value)
    }
}

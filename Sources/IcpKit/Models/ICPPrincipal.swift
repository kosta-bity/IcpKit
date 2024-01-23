//
//  ICPPrincipal.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 19.04.23.
//

import Foundation

/// from https://internetcomputer.org/docs/current/references/ic-interface-spec/#principal
public struct ICPPrincipal {
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

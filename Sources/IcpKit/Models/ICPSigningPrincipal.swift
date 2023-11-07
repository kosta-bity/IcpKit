//
//  ICPSigningPrincipal.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public protocol ICPSigningPrincipal {
    var principal: ICPPrincipal { get }
    var rawPublicKey: Data { get }
    
    /// All implementations of this method must ultimately call `ICPCryptography.ellipticSign` with the appropriate private key and return the result
    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data
}

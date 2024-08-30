//
//  ICPNftActor.swift
//
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import IcpKit

public protocol ICPNftActor {
    var standard: ICPNftStandard { get }
    
    init(_ canister: ICPPrincipal)
    
    func allNfts() async throws -> [ICPNftDetails]
    func nftDetails(_ tokenIndex: ICPNftDetails.Index) async throws -> ICPNftDetails
    
    func userTokens(_ principal: ICPPrincipal) async throws -> [ICPNftDetails]
    func transfer(from: ICPSigningPrincipal, to principal: ICPPrincipal, _ tokenIndex: ICPNftDetails.Index) async throws
}

public enum ICPNftActorError: Error {
    case nftNotFound
    case invalidIndex
    case invalidMetaData
}

public extension ICPNftActor {
    init(_ canister: String) throws {
        self.init(try ICPPrincipal(canister))
    }
}

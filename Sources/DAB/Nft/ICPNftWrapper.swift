//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import Candid

public protocol ICPNftWrapper {
    var standard: ICPNftStandard { get }
    
    func nftCollection() async throws -> ICPNftCollection
    func nftDetails(_ tokenIndex: String) async throws -> ICPNftDetails
    
    func userTokens(_ principal: any CandidPrincipalProtocol) async throws -> [ICPNftDetails]
    func transfer(_ principal: any CandidPrincipalProtocol, _ tokenIndex: String) async throws
}

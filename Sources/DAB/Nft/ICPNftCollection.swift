//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import Candid

public struct ICPNftCollection {
    public let standard: ICPNftStandard
    
    public let name: String
    public let description: String
    public let icon: URL?

    public let tokens: [ICPNftDetails]
    public let canister: any CandidPrincipalProtocol
}

//
//  ICPNftCollection.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import IcpKit

public struct ICPNftCollection: Sendable {
    public let standard: ICPNftStandard
    
    public let name: String
    public let description: String
    public let icon: URL?

    public let canister: ICPPrincipal
    
    public init(standard: ICPNftStandard, name: String, description: String, icon: URL?, canister: ICPPrincipal) {
        self.standard = standard
        self.name = name
        self.description = description
        self.icon = icon
        self.canister = canister
    }
}

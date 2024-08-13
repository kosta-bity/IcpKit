//
//  ICPService.swift
//
//
//  Created by Konstantinos Gaitanis on 06.08.24.
//

import Foundation

open class ICPService {
    public let canister: ICPPrincipal
    public let client: ICPRequestClient
    
    public init(canister: ICPPrincipal, client: ICPRequestClient) {
        self.canister = canister
        self.client = client
    }
}

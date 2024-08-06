//
//  ICPService.swift
//
//
//  Created by Konstantinos Gaitanis on 06.08.24.
//

import Foundation

public class ICPService {
    public let canister: ICPPrincipal
    public let client: ICPRequestClient
    
    public init(canister: ICPPrincipal, client: ICPRequestClient) {
        self.canister = canister
        self.client = client
    }
}

//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation
import IcpKit

public class ICPTokenActorFactory {
    public static func actorType(for standard: ICPTokenStandard) -> (any ICPTokenActor.Type)? {
        switch standard {
        case .dip20: return nil
        case .xtc: return nil
        case .wIcp: return nil
        case .ext: return nil
        case .icp: return nil
        case .rosetta: return nil
        case .icrc1: return ICRC1TokenActor.self
        case .icrc2: return nil
        case .drc20: return nil
        }
    }
    
    public static func `actor`(for standard: ICPTokenStandard, _ canister: ICPPrincipal, _ client: ICPRequestClient) -> ICPTokenActor? {
        actorType(for: standard)?.init(canister, client)
    }
    
    public static func `actor`(for token: ICPToken, _ client: ICPRequestClient) -> ICPTokenActor? {
        actorType(for: token.standard)?.init(token.canister, client)
    }
}

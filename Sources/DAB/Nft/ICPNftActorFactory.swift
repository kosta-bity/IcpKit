//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 28.08.24.
//

import Foundation
import IcpKit

public class ICPNftActorFactory {
    public static func actorType(for standard: ICPNftStandard) -> any ICPNftActor.Type {
        switch standard {
        case .ext: return EXTNftActor.self
        case .icrc7: return ICRC7NftActor.self
        case .origynNft: return OrigynNftActor.self
        }
    }
    
    public static func `actor`(for standard: ICPNftStandard, _ canister: ICPPrincipal, _ client: ICPRequestClient) -> ICPNftActor {
        actorType(for: standard).init(canister, client)
    }
}

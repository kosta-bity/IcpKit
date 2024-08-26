//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import BigInt

public struct ICPNftDetails {
    public enum Index {
        case number(BigUInt)
        case string(String)
    }
    public let standard: ICPNftStandard
    
    public let index: Index
    public let name: String?
    public let url: URL
    public let metadata: Any    // TODO: structure this
    public let `operator`: String?
}

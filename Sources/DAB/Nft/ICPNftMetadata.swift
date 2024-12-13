//
//  ICPNftMetadata.swift
//
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import Foundation

struct ICPNftMetadata {
    enum Value {
        case text(String)
        case array([Value])
        case map([(String, Value)])
    }
    let properties: [(String, Value)]
}


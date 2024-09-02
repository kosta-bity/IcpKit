//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}

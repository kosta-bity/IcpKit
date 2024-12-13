//
//  URL+ExpressibleByStringLiteral.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation

extension URL: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension URL: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension URL: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}

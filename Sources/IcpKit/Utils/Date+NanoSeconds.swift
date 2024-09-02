//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation

public extension Date {
    var nanoSecondsSince1970: UInt64 { UInt64(timeIntervalSince1970 * 1e9) }
}

//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 06.08.24.
//

import Foundation

public protocol StaticBool {
    static var value: Bool { get }
}

@frozen public enum StaticFalse: StaticBool {
    public static let value: Bool = false
}
@frozen public enum StaticTrue: StaticBool {
    public static let value: Bool = true
}

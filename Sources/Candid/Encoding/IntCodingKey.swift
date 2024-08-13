//
//  IntCodingKey.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import Foundation

internal struct IntCodingKey: CodingKey {
    var stringValue: String { return String(intValue!) }
    init?(stringValue: String) { fatalError() }
    let intValue: Int?
    init(intValue: Int) { self.intValue = intValue }
}

//
//  CandidCodingKey.swift
//
//
//  Created by Konstantinos Gaitanis on 12.08.24.
//

import Foundation

public protocol CandidCodingKey: CodingKey, CaseIterable {}
public extension CandidCodingKey {
    init?(intValue: Int) {
        guard let value = Self.allCases.first(where: { $0.intValue == intValue || CandidKey.candidHash($0.stringValue) == intValue }) else {
            return nil
        }
        self = value
    }
}

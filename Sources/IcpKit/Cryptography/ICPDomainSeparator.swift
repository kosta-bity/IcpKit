//
//  ICPDomainSeparator.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 04.05.23.
//

import Foundation

public struct ICPDomainSeparator {
    public let data: Data
    public let domain: String
    
    public init(_ domain: String) {
        self.domain = domain
        self.data = ICPCryptography.Leb128.encodeUnsigned(domain.count) + Data(domain.utf8)
    }
    
    public func domainSeparatedData(_ data: any DataProtocol) -> Data {
        return self.data + data
    }
}

extension ICPDomainSeparator: ExpressibleByStringLiteral {
    public init(stringLiteral domain: String) {
        self.init(domain)
    }
}

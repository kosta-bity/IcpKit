//
//  CandidPrincipal.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

public protocol CandidPrincipalProtocol: Equatable, Codable {
    var bytes: Data { get }
    var string: String { get }
    
    init(_ string: String) throws
    init(_ bytes: Data)
}

public extension CandidPrincipalProtocol {
    init(_ other: any CandidPrincipalProtocol) {
        self.init(other.bytes)
    }
}

public struct CandidPrincipal: CandidPrincipalProtocol {
    public let bytes: Data
    public let string: String
    
    public init(_ string: String) throws {
        self.string = string
        self.bytes = try CanonicalText.decode(string)
    }
    
    public init(_ bytes: Data) {
        self.bytes = bytes
        self.string = CanonicalText.encode(bytes)
    }
}

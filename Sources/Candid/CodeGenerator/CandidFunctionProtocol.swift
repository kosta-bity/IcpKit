//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation

public protocol CandidFunctionProtocol: Codable {
    var canister: CandidPrincipal { get }
    var method: String { get }
    var query: Bool { get }
    
    init(_ canister: CandidPrincipal, _ method: String, _ query: Bool)
}

extension CandidFunctionProtocol {
    public init(from decoder: Decoder) throws {
        fatalError("not supported. Use CandidDecoder() instead.")
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError("not supported. Use CandidEncoder() instead.")
    }
}

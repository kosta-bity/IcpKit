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

public extension CandidFunctionProtocol {
    init(from decoder: Decoder) throws {
        fatalError("not supported. Use CandidDecoder() instead.")
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError("not supported. Use CandidEncoder() instead.")
    }
}

public protocol CandidFunctionSignatureProtocol {
    static var signature: CandidFunctionSignature { get }
}

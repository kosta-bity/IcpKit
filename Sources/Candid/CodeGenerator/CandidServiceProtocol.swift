//
//  CandidServiceProtocol.swift
//
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation

public protocol CandidServiceProtocol: Codable {
    var principal: CandidPrincipal { get }
    
    init(_ principal: CandidPrincipal)
}

public extension CandidServiceProtocol {
    init(from decoder: Decoder) throws {
        fatalError("not supported. Use CandidDecoder instead")
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError("not supported. Use CandidEncoder instead")
    }
}

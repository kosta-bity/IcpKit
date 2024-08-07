//
//  CandidVector.swift
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation

public struct CandidVector: Equatable, Codable {
    //public typealias Element = CandidValue
    
    private enum CandidVectorError: Error {
        case noElementsAndNoType
        case wrongCandidType
    }
    
    public let values: [CandidValue]
    public let containedType: CandidType
    
    public init(_ containedType: CandidType) {
        self.containedType = containedType
        self.values = []
    }
    
    public init(_ sequence: any Sequence<CandidValue>) throws {
        guard let firstType = sequence.first(where: { _ in true })?.candidType else {
            throw CandidVectorError.noElementsAndNoType
        }
        let lowestSubType = sequence.reduce(firstType) { (result, element) in
            result.isSubType(of: element.candidType) ? result : element.candidType
        }
        try self.init(lowestSubType, sequence)
    }
    
    public init(_ type: CandidType, _ sequence: any Sequence<CandidValue>) throws {
        guard sequence.allSatisfy({ $0.candidType == type }) else {
        //guard sequence.allSatisfy({ $0.candidType.isSuperType(of: type) }) else {
            throw CandidVectorError.wrongCandidType
        }
        values = Array(sequence)
        self.containedType = type
    }
}

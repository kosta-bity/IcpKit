//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 10.09.24.
//

import Foundation
import Candid
import Combine

public class ICPFunctionArgsCoder: TopLevelEncoder, TopLevelDecoder {
    public init() {}
    
    public func encode<T>(_ value: T) throws -> [CandidValue] where T : Encodable {
        if let multiArgs = value as? any ICPFunctionArgsEncodable {
            return try multiArgs.candidEncode()
            
        } else {
            return [try CandidEncoder().encode(value)]
        }
    }
    
    public func decode<T>(_ values: [CandidValue]) throws -> T where T : Decodable {
        try decode(T.self, from: values)
    }
        
    public func decode<T>(_ type: T.Type, from values: [CandidValue]) throws -> T where T : Decodable {
        if let multiResultDecodableType = type as? any ICPFunctionArgsDecodable.Type {
            return try multiResultDecodableType.init(values) as! T
        } else {
            guard let firstValue = values.first, values.count == 1 else {
                throw DecodingError.typeMismatch(type, .init(codingPath: [], debugDescription: "Trying to decode a single value but instead have \(values.count) values"))
            }
            return try CandidDecoder().decode(firstValue)
        }
    }
}

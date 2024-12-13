//
//  ICPRequestContent.swift
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation
import Candid

public protocol ICPRequestContent: Encodable {
    var request_type: ICPRequestTypeEncodable { get }
    var sender: Data { get }
    var nonce: Data { get }
    var ingress_expiry: Int { get }
}

public extension ICPRequestContent {
    func calculateRequestId() throws -> Data {
        try OrderIndependentHasher.orderIndependentHash(self)
    }
}

public struct ReadStateRequestContent: ICPRequestContent {
    public let request_type: ICPRequestTypeEncodable
    public let sender: Data
    public let nonce: Data
    public let ingress_expiry: Int
    
    public let paths: [[Data]]
}

public struct CallRequestContent: ICPRequestContent {
    public let request_type: ICPRequestTypeEncodable
    public let sender: Data
    public let nonce: Data
    public let ingress_expiry: Int
    
    public let method_name: String
    public let canister_id: Data
    public let arg: Data
}

public enum ICPRequestTypeEncodable: String, Encodable {
    case call       = "call"
    case query      = "query"
    case readState  = "read_state"
    
    public static func from(_ requestType: ICPRequestType) -> ICPRequestTypeEncodable {
        switch requestType {
        case .call: return .call
        case .query: return .query
        case .readState: return .readState
        }
    }
}



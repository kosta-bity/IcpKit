//
//  ICPRequestContent.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation

protocol ICPRequestContent: Encodable {
    var request_type: ICPRequestTypeEncodable { get }
    var sender: Data { get }
    var nonce: Data { get }
    var ingress_expiry: Int { get }
}

extension ICPRequestContent {
    func calculateRequestId() throws -> Data {
        try ICPCryptography.orderIndependentHash(self)
    }
}

struct ReadStateRequestContent: ICPRequestContent {
    let request_type: ICPRequestTypeEncodable
    let sender: Data
    let nonce: Data
    let ingress_expiry: Int
    
    let paths: [[Data]]
}

struct CallRequestContent: ICPRequestContent {
    let request_type: ICPRequestTypeEncodable
    let sender: Data
    let nonce: Data
    let ingress_expiry: Int
    
    let method_name: String
    let canister_id: Data
    let arg: Data
}

enum ICPRequestTypeEncodable: String, Encodable {
    case call       = "call"
    case query      = "query"
    case readState  = "read_state"
    
    static func from(_ requestType: ICPRequestType) -> ICPRequestTypeEncodable {
        switch requestType {
        case .call: return .call
        case .query: return .query
        case .readState: return .readState
        }
    }
}



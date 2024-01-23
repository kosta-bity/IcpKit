//
//  ICPRequestEnvelope.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation

struct ICPRequestEnvelope: Encodable {
    let content: ICPRequestContent
    let sender_pubkey: Data?
    let sender_sig: Data?
    
    init(content: ICPRequestContent, sender_pubkey: Data, sender_sig: Data) {
        self.content = content
        self.sender_pubkey = sender_pubkey
        self.sender_sig = sender_sig
    }
    
    init(content: ICPRequestContent) {
        self.content = content
        self.sender_pubkey = nil
        self.sender_sig = nil
    }
    
    func encode(to encoder: Encoder) throws {
        enum Keys: String, CodingKey { case content, sender_pubkey, sender_sig }
        var container = encoder.container(keyedBy: Keys.self)
        if let readStateContent = content as? ReadStateRequestContent {
            try container.encode(readStateContent, forKey: Keys.content)
        } else if let callContent = content as? CallRequestContent {
            try container.encode(callContent, forKey: Keys.content)
        } else {
            throw ICPRequestEnvelopeEncodingError.invalidContent
        }
        try container.encode(sender_pubkey, forKey: Keys.sender_pubkey)
        try container.encode(sender_sig, forKey: Keys.sender_sig)
    }
    
    private enum ICPRequestEnvelopeEncodingError: Error {
        case invalidContent
    }
}

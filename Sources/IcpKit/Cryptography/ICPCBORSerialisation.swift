//
//  ICPCBORSerialisation.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation
import PotentCBOR

public extension ICPCryptography {
    enum CBOR {
        public static func serialise(_ value: any Encodable, wrapWithCborTag: Bool = true) throws -> Data {
            var cbor = try CBOREncoder.default.encodeTree(value)
            if wrapWithCborTag {
                // wrap everything in a CBOR self describe tag (55799)
                cbor = PotentCBOR.CBOR.tagged(.selfDescribeCBOR, cbor)
            }
            let serialised = try CBORSerialization.data(from: cbor)
            return serialised
        }
        
        public static func deserialise<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
            let cbor = try deserialiseCbor(from: data)
            let decoded = try CBORDecoder.default.decodeTree(type, from: cbor)
            return decoded
        }
        
        public static func deserialiseCbor(from data: Data) throws -> PotentCBOR.CBOR {
            let cbor = try CBORSerialization.cbor(from: data)
            return cbor.untagged
        }
    }
}

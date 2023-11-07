//
//  Base32.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import Base32

extension Cryptography {
    enum base32 {
        static func encode(_ data: any DataProtocol) -> String {
            return Base32.encode(Data(data))
        }
        
        static func decode(_ string: any StringProtocol) throws -> Data {
            return try Base32.decode(String(string))
        }
    }
}

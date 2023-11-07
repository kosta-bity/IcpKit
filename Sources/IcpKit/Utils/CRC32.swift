//
//  CRC32.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 19.04.23.
//

import Foundation
import zlib

extension Cryptography {
    static let crc32Length: Int = 4
    /// CRC32 is a four byte check sequence, calculated as defined by ISO 3309, ITU-T V.42, and elsewhere, and stored as big-endian, i.e., the most significant byte comes first and then the less significant bytes come in descending order of significance (MSB B2 B1 LSB).
    static func crc32(_ data: any DataProtocol) -> Data {
        let checksum = Data(data).withUnsafeBytes {
            zlib.crc32(0, $0.bindMemory(to: Bytef.self).baseAddress, uInt(data.count))
        }
        let last4Bytes = checksum.bigEndianBytes.suffix(self.crc32Length)
        return Data(last4Bytes)
    }
}

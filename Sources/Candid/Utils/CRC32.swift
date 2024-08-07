//
//  CRC32.swift
//
//  Created by Konstantinos Gaitanis on 19.04.23.
//

import Foundation
import zlib

public enum CRC32 {
    public static let length: Int = 4
    /// CRC32 is a four byte check sequence, calculated as defined by ISO 3309, ITU-T V.42, and elsewhere, and stored as big-endian, i.e., the most significant byte comes first and then the less significant bytes come in descending order of significance (MSB B2 B1 LSB).
    public static func checksum(_ data: any DataProtocol) -> Data {
        let checksum = Data(data).withUnsafeBytes {
            zlib.crc32(0, $0.bindMemory(to: Bytef.self).baseAddress, uInt(data.count))
        }
        let last4Bytes = checksum.bigEndianBytes.suffix(self.length)
        return Data(last4Bytes)
    }
}

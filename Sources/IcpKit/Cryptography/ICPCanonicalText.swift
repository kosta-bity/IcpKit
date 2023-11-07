//
//  ICPCanonicalText.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import Foundation

public extension ICPCryptography {
    private static let canonicalTextSeparator: String = "-"
    ///
    ///     The canonical textual representation of a blob b is
    ///         Grouped(Base32(CRC32(b) · b))
    ///
    ///     where:
    ///    - CRC32 is a four byte check sequence, calculated as defined by ISO 3309, ITU-T V.42, and elsewhere, and stored as big-endian, i.e., the most significant byte comes first and then the less significant bytes come in descending order of significance (MSB B2 B1 LSB).
    ///    - Base32 is the Base32 encoding as defined in RFC 4648, with no padding character added.
    ///    - The middle dot denotes concatenation.
    ///    - Grouped takes an ASCII string and inserts the separator - (dash) every 5 characters. The last group may contain less than 5 characters. A separator never appears at the beginning or end.
    static func encodeCanonicalText(_ data: Data) -> String {
        let checksum = Cryptography.crc32(data)
        let dataWithChecksum = checksum + data
        let base32Encoded = Cryptography.base32.encode(dataWithChecksum).lowercased().filter { $0 != "=" }
        let grouped = base32Encoded.grouped(by: canonicalTextSeparator, every: 5)
        return grouped
    }
    
    static func decodeCanonicalText(_ text: String) throws -> Data {
        let degrouped = text.replacingOccurrences(of: canonicalTextSeparator, with: "")
        let base32Encoded: String
        if degrouped.count % 2 != 0 { base32Encoded = degrouped + "=" }
        else { base32Encoded = degrouped }
        let decoded = try Cryptography.base32.decode(base32Encoded)
        let data = decoded.suffix(from: Cryptography.crc32Length)
        return data
    }
}

private extension Collection {
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence,Index> {
        sequence(state: startIndex) { start in
            guard start < endIndex else { return nil }
            let end = index(start, offsetBy: maxLength, limitedBy: endIndex) ?? endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}

private extension StringProtocol where Self: RangeReplaceableCollection {
    func grouped(by separator: any StringProtocol, every groupLength: Int) -> String {
        return String(unfoldSubSequences(limitedTo: groupLength).joined(separator: separator))
    }
}

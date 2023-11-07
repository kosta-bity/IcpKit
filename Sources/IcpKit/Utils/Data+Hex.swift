//
//  Data+hex.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 23.11.22.
//

import Foundation

extension DataProtocol {
    public var hex: String {
        self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    public static func fromHex(_ string: any StringProtocol) -> Data? {
        guard string.count.isMultiple(of: 2) else {
            return nil
        }
        var data = Data()
        var index = string.startIndex
        while index != string.endIndex {
            let subString = string[index...string.index(after: index)]
            guard let byte = UInt8(subString, radix: 16) else {
                return nil
            }
            data.append(contentsOf: [byte])
            index = string.index(index, offsetBy: 2)
        }
        return data
    }
}

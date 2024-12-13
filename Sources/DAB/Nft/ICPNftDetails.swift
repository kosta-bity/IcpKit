//
//  ICPNftDetails.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import IcpKit
import BigInt

public struct ICPNftDetails {
    public let standard: ICPNftStandard
    
    public let index: Index
    public let name: String?
    public let url: URL
    public let metadata: Any?    // TODO: structure this
    public let `operator`: String?
    public let canister: ICPPrincipal
    
    public init(standard: ICPNftStandard, index: Index, name: String?, url: URL, metadata: Any?, `operator`: String?, canister: ICPPrincipal) {
        self.standard = standard
        self.index = index
        self.name = name
        self.url = url
        self.metadata = metadata
        self.operator = `operator`
        self.canister = canister
    }
    
    public enum Index {
        public enum IndexError: Error {
            case notANumber
            case notAString
        }
        case number(BigUInt)
        case string(String)
    }
}

public extension ICPNftDetails.Index {
    func number() throws -> BigUInt {
        guard case .number(let bigUInt) = self else {
            throw IndexError.notANumber
        }
        return bigUInt
    }
    
    func string() throws -> String {
        guard case .string(let string) = self else {
            throw IndexError.notAString
        }
        return string
    }
}

extension ICPNftDetails.Index: CustomStringConvertible {
    public var description: String {
        switch self {
        case .number(let bigUInt): return bigUInt.description
        case .string(let string): return string
        }
    }
}

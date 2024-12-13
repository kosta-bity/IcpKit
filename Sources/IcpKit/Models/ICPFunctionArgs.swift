//
//  ICPFunctionArgs.swift
//
//
//  Created by Konstantinos Gaitanis on 09.09.24.
//

import Foundation
import Candid

// MARK: Implementations
public struct ICPFunctionArgs2<T0, T1> {
    public let _0: T0
    public let _1: T1
    public var tuple: (T0, T1) { (_0, _1) }
    public init(_ _0: T0, _ _1: T1) {
        self._0 = _0
        self._1 = _1
    }
}

public struct ICPFunctionArgs3<T0, T1, T2> {
    public let _0: T0
    public let _1: T1
    public let _2: T2
    public var tuple: (T0, T1, T2) { (_0, _1, _2) }
    public init(_ _0: T0, _ _1: T1, _ _2: T2) {
        self._0 = _0
        self._1 = _1
        self._2 = _2
    }
}

public struct ICPFunctionArgs4<T0, T1, T2, T3> {
    public let _0: T0
    public let _1: T1
    public let _2: T2
    public let _3: T3
    public var tuple: (T0, T1, T2, T3) { (_0, _1, _2, _3) }
    public init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3) {
        self._0 = _0
        self._1 = _1
        self._2 = _2
        self._3 = _3
    }
}

public struct ICPFunctionArgs5<T0, T1, T2, T3, T4> {
    public let _0: T0
    public let _1: T1
    public let _2: T2
    public let _3: T3
    public let _4: T4
    public var tuple: (T0, T1, T2, T3, T4) { (_0, _1, _2, _3, _4) }
    public init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3, _ _4: T4) {
        self._0 = _0
        self._1 = _1
        self._2 = _2
        self._3 = _3
        self._4 = _4
    }
}

public struct ICPFunctionArgs6<T0, T1, T2, T3, T4, T5> {
    public let _0: T0
    public let _1: T1
    public let _2: T2
    public let _3: T3
    public let _4: T4
    public let _5: T5
    public var tuple: (T0, T1, T2, T3, T4, T5) { (_0, _1, _2, _3, _4, _5) }
    public init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3, _ _4: T4, _ _5: T5) {
        self._0 = _0
        self._1 = _1
        self._2 = _2
        self._3 = _3
        self._4 = _4
        self._5 = _5
    }
}

public struct ICPFunctionArgs7<T0, T1, T2, T3, T4, T5, T6> {
    public let _0: T0
    public let _1: T1
    public let _2: T2
    public let _3: T3
    public let _4: T4
    public let _5: T5
    public let _6: T6
    public var tuple: (T0, T1, T2, T3, T4, T5, T6) { (_0, _1, _2, _3, _4, _5, _6) }
    public init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3, _ _4: T4, _ _5: T5, _ _6: T6) {
        self._0 = _0
        self._1 = _1
        self._2 = _2
        self._3 = _3
        self._4 = _4
        self._5 = _5
        self._6 = _6
    }
}

// MARK: Protocols
protocol ICPFunctionArgsDecodable: Decodable {
    init(_ values: [CandidValue]) throws
}
protocol ICPFunctionArgsEncodable: Encodable {
    func candidEncode() throws -> [CandidValue]
}

// MARK: Decoding from CandidValues
extension ICPFunctionArgs2: Decodable, ICPFunctionArgsDecodable where T0: Decodable, T1: Decodable {
    init(_ values: [Candid.CandidValue]) throws {
        guard values.count == 2 else {
            throw decodingError(2, values.count)
        }
        self.init(
            try CandidDecoder().decode(values[0]),
            try CandidDecoder().decode(values[1])
        )
    }
}
extension ICPFunctionArgs3: Decodable, ICPFunctionArgsDecodable where T0: Decodable, T1: Decodable, T2: Decodable {
    init(_ values: [Candid.CandidValue]) throws {
        guard values.count == 3 else {
            throw decodingError(3, values.count)
        }
        self.init(
            try CandidDecoder().decode(values[0]),
            try CandidDecoder().decode(values[1]),
            try CandidDecoder().decode(values[2])
        )
    }
}
extension ICPFunctionArgs4: Decodable, ICPFunctionArgsDecodable where T0: Decodable, T1: Decodable, T2: Decodable, T3: Decodable {
    init(_ values: [Candid.CandidValue]) throws {
        guard values.count == 4 else {
            throw decodingError(4, values.count)
        }
        self.init(
            try CandidDecoder().decode(values[0]),
            try CandidDecoder().decode(values[1]),
            try CandidDecoder().decode(values[2]),
            try CandidDecoder().decode(values[3])
        )
    }
}
extension ICPFunctionArgs5: Decodable, ICPFunctionArgsDecodable where T0: Decodable, T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable {
    init(_ values: [Candid.CandidValue]) throws {
        guard values.count == 5 else {
            throw decodingError(5, values.count)
        }
        self.init(
            try CandidDecoder().decode(values[0]),
            try CandidDecoder().decode(values[1]),
            try CandidDecoder().decode(values[2]),
            try CandidDecoder().decode(values[3]),
            try CandidDecoder().decode(values[4])
        )
    }
}
extension ICPFunctionArgs6: Decodable, ICPFunctionArgsDecodable where T0: Decodable, T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable, T5: Decodable {
    init(_ values: [Candid.CandidValue]) throws {
        guard values.count == 6 else {
            throw decodingError(6, values.count)
        }
        self.init(
            try CandidDecoder().decode(values[0]),
            try CandidDecoder().decode(values[1]),
            try CandidDecoder().decode(values[2]),
            try CandidDecoder().decode(values[3]),
            try CandidDecoder().decode(values[4]),
            try CandidDecoder().decode(values[5])
        )
    }
}
extension ICPFunctionArgs7: Decodable, ICPFunctionArgsDecodable where T0: Decodable, T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable, T5: Decodable, T6: Decodable {
    init(_ values: [Candid.CandidValue]) throws {
        guard values.count == 7 else {
            throw decodingError(7, values.count)
        }
        self.init(
            try CandidDecoder().decode(values[0]),
            try CandidDecoder().decode(values[1]),
            try CandidDecoder().decode(values[2]),
            try CandidDecoder().decode(values[3]),
            try CandidDecoder().decode(values[4]),
            try CandidDecoder().decode(values[5]),
            try CandidDecoder().decode(values[6])
        )
    }
}

private func decodingError(_ expecting: Int, _ got: Int) -> Error { DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Trying to decode \(expecting) values but instead have \(got) Candid Values")) }

// MARK: Encoding to CandidValues
extension ICPFunctionArgs2: Encodable, ICPFunctionArgsEncodable where T0: Encodable, T1: Encodable {
    func candidEncode() throws -> [CandidValue] {
        [
            try CandidEncoder().encode(_0),
            try CandidEncoder().encode(_1),
        ]
    }
}

extension ICPFunctionArgs3: Encodable, ICPFunctionArgsEncodable where T0: Encodable, T1: Encodable, T2: Encodable {
    func candidEncode() throws -> [CandidValue] {
        [
            try CandidEncoder().encode(_0),
            try CandidEncoder().encode(_1),
            try CandidEncoder().encode(_2),
        ]
    }
}

extension ICPFunctionArgs4: Encodable, ICPFunctionArgsEncodable where T0: Encodable, T1: Encodable, T2: Encodable, T3: Encodable {
    func candidEncode() throws -> [CandidValue] {
        [
            try CandidEncoder().encode(_0),
            try CandidEncoder().encode(_1),
            try CandidEncoder().encode(_2),
            try CandidEncoder().encode(_3),
        ]
    }
}

extension ICPFunctionArgs5: Encodable, ICPFunctionArgsEncodable where T0: Encodable, T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable {
    func candidEncode() throws -> [CandidValue] {
        [
            try CandidEncoder().encode(_0),
            try CandidEncoder().encode(_1),
            try CandidEncoder().encode(_2),
            try CandidEncoder().encode(_3),
            try CandidEncoder().encode(_4),
        ]
    }
}

extension ICPFunctionArgs6: Encodable, ICPFunctionArgsEncodable where T0: Encodable, T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable {
    func candidEncode() throws -> [CandidValue] {
        [
            try CandidEncoder().encode(_0),
            try CandidEncoder().encode(_1),
            try CandidEncoder().encode(_2),
            try CandidEncoder().encode(_3),
            try CandidEncoder().encode(_4),
            try CandidEncoder().encode(_5),
        ]
    }
}

extension ICPFunctionArgs7: Encodable, ICPFunctionArgsEncodable where T0: Encodable, T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable {
    func candidEncode() throws -> [CandidValue] {
        [
            try CandidEncoder().encode(_0),
            try CandidEncoder().encode(_1),
            try CandidEncoder().encode(_2),
            try CandidEncoder().encode(_3),
            try CandidEncoder().encode(_4),
            try CandidEncoder().encode(_5),
            try CandidEncoder().encode(_6),
        ]
    }
}

extension ICPFunctionArgs2: Equatable where T0: Equatable, T1: Equatable {}
extension ICPFunctionArgs3: Equatable where T0: Equatable, T1: Equatable, T2: Equatable {}
extension ICPFunctionArgs4: Equatable where T0: Equatable, T1: Equatable, T2: Equatable, T3: Equatable {}
extension ICPFunctionArgs5: Equatable where T0: Equatable, T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable {}
extension ICPFunctionArgs6: Equatable where T0: Equatable, T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable {}
extension ICPFunctionArgs7: Equatable where T0: Equatable, T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable {}

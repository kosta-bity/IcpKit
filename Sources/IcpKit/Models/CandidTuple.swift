//
//  CandidTuple.swift
//
//
//  Created by Konstantinos Gaitanis on 05.08.24.
//

import Foundation

public struct CandidTuple2<T0, T1> {
    public let _0: T0
    public let _1: T1
    public var tuple: (T0, T1) { (_0, _1) }
    
    public init(_ _0: T0, _ _1: T1) {
        self._0 = _0
        self._1 = _1
    }
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
    }
}

public struct CandidTuple3<T0, T1, T2> {
    public let _0: T0
    public let _1: T1
    public let _2: T2
    public var tuple: (T0, T1, T2) { (_0, _1, _2) }
    
    public init(_ _0: T0, _ _1: T1, _ _2: T2) {
        self._0 = _0
        self._1 = _1
        self._2 = _2
    }
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
        case _2 = 2
    }
}

public struct CandidTuple4<T0, T1, T2, T3> {
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
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
        case _2 = 2
        case _3 = 3
    }
}

public struct CandidTuple5<T0, T1, T2, T3, T4> {
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
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
        case _2 = 2
        case _3 = 3
        case _4 = 4
    }
}

public struct CandidTuple6<T0, T1, T2, T3, T4, T5> {
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
    
    enum CodingKeys: Int, CodingKey {
        case _0 = 0
        case _1 = 1
        case _2 = 2
        case _3 = 3
        case _4 = 4
        case _5 = 5
    }
}

extension CandidTuple2: Encodable where T0: Encodable, T1: Encodable {}
extension CandidTuple2: Decodable where T0: Decodable, T1: Decodable {}
extension CandidTuple3: Encodable where T0: Encodable, T1: Encodable, T2: Encodable {}
extension CandidTuple3: Decodable where T0: Decodable, T1: Decodable, T2: Decodable {}
extension CandidTuple4: Encodable where T0: Encodable, T1: Encodable, T2: Encodable, T3: Encodable {}
extension CandidTuple4: Decodable where T0: Decodable, T1: Decodable, T2: Decodable, T3: Decodable {}
extension CandidTuple5: Encodable where T0: Encodable, T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable {}
extension CandidTuple5: Decodable where T0: Decodable, T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable {}
extension CandidTuple6: Encodable where T0: Encodable, T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable {}
extension CandidTuple6: Decodable where T0: Decodable, T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable, T5: Decodable {}

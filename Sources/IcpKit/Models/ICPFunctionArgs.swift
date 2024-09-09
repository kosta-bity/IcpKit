//
//  ICPFunctionArgs.swift
//
//
//  Created by Konstantinos Gaitanis on 06.09.24.
//

import Foundation

public struct ICPFunctionArgs7<T0, T1, T2, T3, T4, T5, T6>: ICPFunctionArgs {
    public let _0: T0
    public let _1: T1
    public let _2: T2
    public let _3: T3
    public let _4: T4
    public let _5: T5
    public let _6: T6
    
    public init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3, _ _4: T4, _ _5: T5, _ _6: T6) {
        self._0 = _0
        self._1 = _1
        self._2 = _2
        self._3 = _3
        self._4 = _4
        self._5 = _5
        self._6 = _6
    }

    public init(from decoder: Decoder) throws {
        fatalError()
    }
    public func encode(to encoder: Encoder) throws {
        fatalError()
    }
}

protocol ICPFunctionArgs: Codable {
    associatedtype T0
    associatedtype T1
    associatedtype T2
    associatedtype T3
    associatedtype T4
    associatedtype T5
    associatedtype T6
    var _0: T0 { get }
    var _1: T1 { get }
    var _2: T2 { get }
    var _3: T3 { get }
    var _4: T4 { get }
    var _5: T5 { get }
    var _6: T6 { get }
}

public typealias ICPFunctionArgs2<T0, T1>                   = ICPFunctionArgs3<T0, T1, Void>
public typealias ICPFunctionArgs3<T0, T1, T2>               = ICPFunctionArgs4<T0, T1, T2, Void>
public typealias ICPFunctionArgs4<T0, T1, T2, T3>           = ICPFunctionArgs5<T0, T1, T2, T3, Void>
public typealias ICPFunctionArgs5<T0, T1, T2, T3, T4>       = ICPFunctionArgs6<T0, T1, T2, T3, T4, Void>
public typealias ICPFunctionArgs6<T0, T1, T2, T3, T4, T5>   = ICPFunctionArgs7<T0, T1, T2, T3, T4, T5, Void>

public extension ICPFunctionArgs2 {
    init(_ _0: T0, _ _1: T1) { self.init(_0, _1, () as! T2) }
}
public extension ICPFunctionArgs3 {
    init(_ _0: T0, _ _1: T1, _ _2: T2) { self.init(_0, _1, _2, () as! T3) }
}
public extension ICPFunctionArgs4 {
    init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3) { self.init(_0, _1, _2, _3, () as! T4) }
}
public extension ICPFunctionArgs5 {
    init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3, _ _4: T4) { self.init(_0, _1, _2, _3, _4, () as! T5) }
}
public extension ICPFunctionArgs6 {
    init(_ _0: T0, _ _1: T1, _ _2: T2, _ _3: T3, _ _4: T4, _ _5: T5) { self.init(_0, _1, _2, _3, _4, _5, () as! T6) }
}

extension ICPFunctionArgs {
    public func map<R>(_ transform: (Encodable) throws -> R) throws -> [R] {
        [
            try mapItem(_0, transform),
            try mapItem(_1, transform),
            try mapItem(_2, transform),
            try mapItem(_3, transform),
            try mapItem(_4, transform),
            try mapItem(_5, transform),
            try mapItem(_6, transform),
        ].compactMap { $0 }
    }
    
    private func mapItem<T, I, R>(_ item: T, _ transform: (I) throws -> R) throws -> R? {
        guard let casted = item as? I else { return nil }
        return try transform(casted)
    }
}

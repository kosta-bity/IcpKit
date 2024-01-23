//
//  ICPStateTreePath.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 06.05.23.
//

import Foundation

public struct ICPStateTreePath: Hashable {
    public let components: [ICPStateTreePathComponent]
    
    public init(_ path: String) {
        let splitComponents = path.split(separator: "/").map(String.init)
        self.components = splitComponents.map { .string($0) }
    }
    
    public init(_ components: any Sequence<ICPStateTreePathComponent>) {
        self.components = Array(components)
    }
    
    public var firstComponent: ICPStateTreePathComponent? { components.first }
    public var removingFirstComponent: ICPStateTreePath { .init(components.suffix(from: 1)) }
    public var isEmpty: Bool { components.isEmpty }
}

public enum ICPStateTreePathComponent: Hashable {
    case data(Data)
    case string(String)
    
    public var stringValue: String? {
        guard case .string(let string) = self else { return nil }
        return string
    }
    
    public var dataValue: Data? {
        guard case .data(let data) = self else { return nil }
        return data
    }
}

// MARK: Encoding
public extension ICPStateTreePath {
    func encodedComponents() -> [Data] { components.map { $0.encoded() } }
}

public extension ICPStateTreePathComponent {
    public func encoded() -> Data {
        switch self {
        case .data(let data): return data
        case .string(let string): return Data(string.utf8)
        }
    }
}

// MARK: convenience initialisers
extension ICPStateTreePath: ExpressibleByStringLiteral {
    public init(stringLiteral path: String) {
        self.init(path)
    }
}

extension ICPStateTreePath: ExpressibleByArrayLiteral {
    public init(arrayLiteral components: ICPStateTreePathComponent...) {
        self.init(components)
    }
}

extension ICPStateTreePathComponent: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

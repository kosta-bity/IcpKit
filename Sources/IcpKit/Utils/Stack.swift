//
//  Stack.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 15.04.23.
//

import Foundation

protocol Stackable {
    associatedtype Element
    func peek() -> Element?
    mutating func push(_ element: Element)
    @discardableResult mutating func pop() -> Element?
}

extension Stackable {
    var isEmpty: Bool { peek() == nil }
}

struct Stack<Element>: Stackable {
    private var storage = [Element]()
    func peek() -> Element? { storage.last }
    mutating func push(_ element: Element) { storage.insert(element, at: 0)  }
    mutating func pop() -> Element? { storage.popLast() }
}

extension Stack: Equatable where Element: Equatable {
    static func == (lhs: Stack<Element>, rhs: Stack<Element>) -> Bool { lhs.storage == rhs.storage }
}

extension Stack: CustomStringConvertible {
    var description: String { "\(storage)" }
}

extension Stack: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Self.Element...) { storage = elements }
}

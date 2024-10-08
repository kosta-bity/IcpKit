//
//  IndentedString.swift
//
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import Foundation

class IndentedString {
    private(set) var output: String = ""
    private var indent: Int = 0
    
    init() {}
    
    init(_ lines: String...) {
        for line in lines {
            addLine(line)
        }
    }
    
    static func inline(_ content: String) -> IndentedString {
        let block = IndentedString()
        block.output = content
        return block
    }
    
    func append(_ content: String) {
        if output.suffix(1) == self.newLine { output.append(whiteSpace) }
        output.append(contentsOf: withIndent(content))
    }
    
    func append(_ block: IndentedString) {
        append(block.output)
    }
        
    func increaseIndent() {
        indent += 1
    }
    
    func decreaseIndent() {
        precondition(indent > 0)
        indent -= 1
    }
    
    func addLine(_ content: String) {
        output += whiteSpace + content + newLine
    }
    
    func addLine() {
        output += "\n"
    }
    
    func addBlock(_ block: IndentedString, newLine: Bool = false) {
        if block.output.isEmpty || block.output.replacingOccurrences(of: self.newLine, with: "").isEmpty { return }
        let indented = withIndent(block.output)
        output += whiteSpace + indented + (newLine ? self.newLine : "")
    }
    
    private func withIndent(_ string: String) -> String {
        let lastChar = string.index(before: string.endIndex)
        let indentedString = string.replacingOccurrences(
            of: self.newLine, with: "\(self.newLine)\(whiteSpace)",
            range: string.startIndex..<lastChar // don't replace last \n
        )
        return indentedString
    }
    
    private static let indentationWhiteSpace: String = "\t"
    private let newLine: String = "\n"
    private var whiteSpace: String { String(repeating: Self.indentationWhiteSpace, count: indent) }
}

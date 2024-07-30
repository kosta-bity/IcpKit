//
//  IndentedString.swift
//
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import Foundation

class IndentedString {
    private (set) var output: String = ""
    private var indent: Int = 0
    
    init() {}
    
    init(_ lines: String...) {
        for line in lines {
            addLine(line)
        }
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
        if block.output.isEmpty { return }
        let indentedBlock = block.output.replacingOccurrences(
            of: self.newLine, with: "\n\(whiteSpace)",
            range: block.output.startIndex..<block.output.index(before: block.output.endIndex) // don't replace last \n
        )
        output += whiteSpace + indentedBlock + (newLine ? self.newLine : "")
    }
    
    private static let indentationWhiteSpace: String = "\t"
    private let newLine: String = "\n"
    private var whiteSpace: String { String(repeating: Self.indentationWhiteSpace, count: indent) }
}

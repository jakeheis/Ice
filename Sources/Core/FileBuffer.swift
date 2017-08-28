//
//  FileBuffer.swift
//  Core
//
//  Created by Jake Heiser on 8/27/17.
//

import Foundation

class FileBuffer {
    
    let path: String
    var lines: [String]
    
    private var indentationLevel = 0
    
    init(path: String) {
        self.path = path
        self.lines = []
    }
    
    func add(_ line: String, indent: Int = 0) {
        let prefix = String(repeating: "    ", count: indentationLevel + indent)
        lines.append(prefix + line)
    }
    
    func add(_ lines: [String], indent: Int = 0) {
        lines.forEach { add($0, indent: indent) }
    }
    
    func indent() {
        indentationLevel += 1
    }
    
    func unindent() {
        indentationLevel -= 1
    }
    
    func write() throws {
        let contents = lines.joined(separator: "\n")
        try contents.write(toFile: path, atomically: true, encoding: .utf8)
    }
    
    func print() {
        Swift.print(lines.joined(separator: "\n"))
    }
    
    static func +=(buffer: FileBuffer, lines: [String]) {
        buffer.add(lines)
    }
    
    static func +=(buffer: FileBuffer, line: String) {
        buffer.add(line)
    }
    
}

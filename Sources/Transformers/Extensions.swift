//
//  Extensions.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Foundation
import Rainbow

public extension String {
    
    var beautifyPath: String {
        var improved = self
        let workingDirPrefix = FileManager.default.currentDirectoryPath
        if hasPrefix(workingDirPrefix) {
            improved = String(self[index(startIndex, offsetBy: workingDirPrefix.characters.count + 1)...])
        }
        var components = improved.components(separatedBy: "/")
        let last = components.removeLast()
        return components.joined(separator: "/").dim + "/\(last)"
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

//
//  Extensions.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation

public extension String {
    
    var quoted: String {
        return "\"\(self)\""
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var trimmingCurrentDirectory: String {
        let workingDirPrefix = FileManager.default.currentDirectoryPath
        if hasPrefix(workingDirPrefix) {
            return String(self[index(startIndex, offsetBy: workingDirPrefix.characters.count + 1)...])
        }
        return self
    }
    
    func commaSeparated() -> [String] {
        return components(separatedBy: ",")
    }
    
}

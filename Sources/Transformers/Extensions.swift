//
//  Extensions.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Foundation

public extension String {
    var trimmingCurrentDirectory: String {
        let workingDirPrefix = FileManager.default.currentDirectoryPath
        if hasPrefix(workingDirPrefix) {
            return String(self[index(startIndex, offsetBy: workingDirPrefix.characters.count + 1)...])
        }
        return self
    }
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

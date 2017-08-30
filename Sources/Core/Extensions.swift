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
    
    func commaSeparated() -> [String] {
        return components(separatedBy: ",")
    }
    
}

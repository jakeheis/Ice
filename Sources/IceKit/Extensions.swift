//
//  Extensions.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

public extension String {
    
    var quoted: String {
        return "\"\(self)\""
    }
    
    func commaSeparated() -> [String] {
        return components(separatedBy: ",")
    }
    
}

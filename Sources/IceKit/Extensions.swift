//
//  Extensions.swift
//  IceKit
//
//  Created by Jake Heiser on 7/21/17.
//

extension String {
    
    public var quoted: String {
        return "\"\(self)\""
    }
    
    public func commaSeparated() -> [String] {
        return components(separatedBy: ",")
    }
    
}

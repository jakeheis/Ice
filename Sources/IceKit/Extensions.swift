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

#if !swift(>=4.1)

public extension Sequence {
    
    func compactMap<U>(_ transform: (Element) -> U?) -> [U] {
        return flatMap(transform)
    }
    
}

#endif

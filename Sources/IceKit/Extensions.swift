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

#if !swift(>=4.1)

extension Sequence {
    
    public func compactMap<U>(_ transform: (Element) -> U?) -> [U] {
        return flatMap(transform)
    }
    
}

#endif

#if !swift(>=4.2)

extension Collection where Element: Equatable {
    
    public func firstIndex(of element: Element) -> Index? {
        return index(of: element)
    }

    public func firstIndex(where test: (Element) throws -> Bool) rethrows -> Index? {
        return try index(where: test)
    }

}

#endif

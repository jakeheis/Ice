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

#if swift(>=4.1.50)

extension Collection {
    public func ice_firstIndex(where test: (Element) throws -> Bool) rethrows -> Index? {
        return try firstIndex(where: test)
    }
}

extension Collection where Element: Equatable {
    public func ice_firstIndex(of element: Element) -> Index? {
        return firstIndex(of: element)
    }
}

#else

extension Collection {
    public func ice_firstIndex(where test: (Element) throws -> Bool) rethrows -> Index? {
        return try index(where: test)
    }
}

extension Collection where Element: Equatable {
    public func ice_firstIndex(of element: Element) -> Index? {
        return index(of: element)
    }
}

#endif

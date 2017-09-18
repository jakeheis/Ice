//
//  Matcher.swift
//  Core
//
//  Created by Jake Heiser on 9/11/17.
//

import Regex

public protocol Matcher: class, CustomStringConvertible {
    static var regex: Regex { get }
    init()
}

public extension Matcher {
    
    var captures: Captures {
        return MatcherManager.captures(for: self)
    }
    
    var description: String {
        return captures.description
    }
    
    public static func matches(_ line: String) -> Bool {
        return regex.matches(line)
    }
    
    public static func findMatch(in line: String) -> Self? {
        return MatcherManager.createMatcher(from: line)
    }
    
    public static func ==<U: Matcher>(lhs: Self, rhs: U) -> Bool {
        return !zip(lhs.captures.captures, rhs.captures.captures).contains(where: { $0 != $1 })
    }
    
}

private class MatcherManager {
    
    private static var map: [ObjectIdentifier: Captures] = [:]
    
    static func createMatcher<T: Matcher>(from line: String) -> T? {
        guard let match = T.regex.firstMatch(in: line) else {
            return nil
        }
        let matcher = T()
        let id = ObjectIdentifier(matcher)
        map[id] = Captures(captures: match.captures)
        return matcher
    }
    
    static func captures<T: Matcher>(for matcher: T) -> Captures {
        let id = ObjectIdentifier(matcher)
        guard let captures = map[id] else {
            fatalError("Cannot create a Matcher manually; must create through Matcher.findMatch()")
        }
        return captures
    }
    
}

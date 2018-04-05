//
//  Matcher.swift
//  Core
//
//  Created by Jake Heiser on 9/11/17.
//

import Regex

open class Matcher: CustomStringConvertible {
    
    public let captures: Captures
    
    public var description: String {
        return captures.description
    }
    
    public required init(captures: Captures) {
        self.captures = captures
    }
    
}

// MARK: -

public protocol Matchable {
    static var regex: Regex { get }
}

public extension Matchable where Self : Matcher {
    static func findMatch(in line: String) -> Self? {
        guard let match = regex.firstMatch(in: line) else {
            return nil
        }
        let matcher = Self(captures: Captures(captures: match.captures))
        return matcher
    }
}

public typealias Line = Matcher & Matchable

// MARK: -

public final class AnyLine: Matcher, Matchable {
    public static let regex = Regex("^(.*)$")
    public var text: String { return captures[0] }
}

public final class WhitespaceLine: Matcher, Matchable {
    public static let regex = Regex("^\\s*$")
}

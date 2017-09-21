//
//  Matcher.swift
//  Core
//
//  Created by Jake Heiser on 9/11/17.
//

import Regex

public protocol Matchable: class, CustomStringConvertible {
    static var regex: Regex { get }
    init()
}

public extension Matchable {
    
    static func findMatch(in line: String) -> Self? {
        return MatcherManager.createMatcher(from: line)
    }
    
    static func ==<U: Matchable>(lhs: Self, rhs: U) -> Bool {
        return !zip(lhs.captures.captures, rhs.captures.captures).contains(where: { $0 != $1 })
    }
    
    var captures: Captures {
        return MatcherManager.captures(for: self)
    }
    
    var description: String {
        return captures.description
    }
    
}

// MARK: -

public protocol Match: Matchable {}

public extension Match {
    static func matches(_ line: String) -> Bool {
        return regex.matches(line)
    }
}

// MARK: -

public protocol Line: Matchable {
    static var stream: StandardStream { get }
}

public extension Line {
    static func matches(_ line: String, _ stream: StandardStream) -> Bool {
        return stream == self.stream && regex.matches(line)
    }
}

public final class AnyOutLine: Line {
    public static let regex = Regex("^(.*)$")
    public static let stream: StandardStream = .out
    public var text: String { return captures[0] }
    public init() {}
}

public final class WhitespaceOutLine: Line {
    public static let regex = Regex("^\\s*$")
    public static let stream: StandardStream = .out
    public init() {}
}

public final class AnyErrLine: Line {
    public static let regex = Regex("^(.*)$")
    public static let stream: StandardStream = .err
    public var text: String { return captures[0] }
    public init() {}
}

public final class WhitespaceErrLine: Line {
    public static let regex = Regex("^\\s*$")
    public static let stream: StandardStream = .out
    public init() {}
}

// MARK: -

private class MatcherManager {
    
    private static var map: [ObjectIdentifier: Captures] = [:]
    
    static func createMatcher<T: Matchable>(from line: String) -> T? {
        guard let match = T.regex.firstMatch(in: line) else {
            return nil
        }
        let matcher = T()
        let id = ObjectIdentifier(matcher)
        map[id] = Captures(captures: match.captures)
        return matcher
    }
    
    static func captures<T: Matchable>(for matcher: T) -> Captures {
        let id = ObjectIdentifier(matcher)
        guard let captures = map[id] else {
            fatalError("Cannot create a Matcher manually; must create through Matcher.findMatch()")
        }
        return captures
    }
    
}

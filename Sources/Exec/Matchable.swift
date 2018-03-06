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

// MARK: -

public protocol StreamMatchable: Matchable {
    static var stream: StandardStream { get }
}

public extension StreamMatchable {
    static func matches(_ line: String, _ stream: StandardStream) -> Bool {
        return stream == self.stream && regex.matches(line)
    }
}

public typealias Line = Matcher & StreamMatchable

// MARK: -

public final class AnyOutLine: Matcher, StreamMatchable {
    public static let regex = Regex("^(.*)$")
    public static let stream: StandardStream = .out
    
    public var text: String { return captures[0] }
}

public final class WhitespaceOutLine: Matcher, StreamMatchable {
    public static let regex = Regex("^\\s*$")
    public static let stream: StandardStream = .out
}

public final class AnyErrLine: Matcher, StreamMatchable {
    public static let regex = Regex("^(.*)$")
    public static let stream: StandardStream = .err
    
    public var text: String { return captures[0] }
}

public final class WhitespaceErrLine: Matcher, StreamMatchable {
    public static let regex = Regex("^\\s*$")
    public static let stream: StandardStream = .out
}

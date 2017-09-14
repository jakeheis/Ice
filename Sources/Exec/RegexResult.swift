//
//  RegexResult.swift
//  Core
//
//  Created by Jake Heiser on 9/11/17.
//

import Regex

public class Captures {
    
    public let captures: [String?]
    
    init(captures: [String?]) {
        self.captures = captures
    }
    
    public subscript<T: Capturable>(index: Int) -> T? {
        guard index < captures.count, let capture = captures[index] else {
            return nil
        }
        return T.fromCapture(capture)
    }
    
    public subscript<T: Capturable>(index: Int) -> T {
        guard let result: T = self[index] else {
            fatalError("\(type(of: self)) error: didn't have required \(index) group")
        }
        return result
    }
    
}

extension Captures: CustomStringConvertible {
    
    public var description: String {
        return captures.description
    }
    
}

open class RegexMatch {
    public let captures: Captures
    required public init(captures: Captures) {
        self.captures = captures
    }
}

extension RegexMatch: Equatable {
    public static func ==(lhs: RegexMatch, rhs: RegexMatch) -> Bool {
        return !zip(lhs.captures.captures, rhs.captures.captures).contains(where: { $0 != $1 })
    }
}

public protocol Matchable {
    static var regex: Regex { get }
}

extension Matchable where Self: RegexMatch {
    
    public static func match(_ line: String) -> Self? {
        guard let match = regex.firstMatch(in: line) else {
            return nil
        }
        let captures = Captures(captures: match.captures)
        return Self(captures: captures)
    }
    
    public static func matches(_ line: String) -> Bool {
        return match(line) != nil
    }
    
}

public protocol Capturable {
    static func fromCapture(_ text: String) -> Self?
}

extension String: Capturable {
    public static func fromCapture(_ text: String) -> String? {
        return text
    }
}
extension Int: Capturable {
    public static func fromCapture(_ text: String) -> Int? {
        return Int(text)
    }
}

extension RawRepresentable where RawValue: Capturable {
    public static func fromCapture(_ text: String) -> Self? {
        guard let value = RawValue.fromCapture(text) else {
            return nil
        }
        return Self.init(rawValue: value)
    }
}

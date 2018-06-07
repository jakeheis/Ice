//
//  Matcher.swift
//  Core
//
//  Created by Jake Heiser on 9/11/17.
//

import Regex

class Matcher: CustomStringConvertible {
    
    let captures: Captures
    
    var description: String {
        return captures.description
    }
    
    required init(captures: Captures) {
        self.captures = captures
    }
    
}

// MARK: -

public protocol Matchable {
    static var regex: Regex { get }
}

extension Matchable where Self : Matcher {
    static func findMatch(in line: String) -> Self? {
        guard let match = regex.firstMatch(in: line) else {
            return nil
        }
        let matcher = Self(captures: Captures(captures: match.captures))
        return matcher
    }
}

typealias Line = Matcher & Matchable

// MARK: -

final class AnyLine: Matcher, Matchable {
    static let regex = Regex("^(.*)$")
    var text: String { return captures[0] }
}

final class WhitespaceLine: Matcher, Matchable {
    static let regex = Regex("^\\s*$")
}

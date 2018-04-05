//
//  Captures.swift
//  Exec
//
//  Created by Jake Heiser on 9/17/17.
//

import SwiftCLI

public class Captures {
    
    public let captures: [String?]
    
    init(captures: [String?]) {
        self.captures = captures
    }
    
    public subscript<T: ConvertibleFromString>(index: Int) -> T? {
        guard index < captures.count, let capture = captures[index] else {
            return nil
        }
        return T.convert(from: capture)
    }
    
    public subscript<T: ConvertibleFromString>(index: Int) -> T {
        guard let result: T = self[index] else {
            preconditionFailure("\(type(of: self)) error: didn't have required \(index) group")
        }
        return result
    }
    
}

extension Captures: CustomStringConvertible {
    public var description: String {
        return captures.description
    }
}

extension Captures: Equatable {
    public static func ==(lhs: Captures, rhs: Captures) -> Bool {
        return !zip(lhs.captures, rhs.captures).contains(where: { $0 != $1 })
    }
}

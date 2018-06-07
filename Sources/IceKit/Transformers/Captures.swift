//
//  Captures.swift
//  Exec
//
//  Created by Jake Heiser on 9/17/17.
//

import SwiftCLI

class Captures {
    
    let captures: [String?]
    
    init(captures: [String?]) {
        self.captures = captures
    }
    
    subscript<T: ConvertibleFromString>(index: Int) -> T? {
        guard index < captures.count, let capture = captures[index] else {
            return nil
        }
        return T.convert(from: capture)
    }
    
    subscript<T: ConvertibleFromString>(index: Int) -> T {
        guard let result: T = self[index] else {
            preconditionFailure("\(type(of: self)) error: didn't have required \(index) group")
        }
        return result
    }
    
}

extension Captures: CustomStringConvertible {
    var description: String {
        return captures.description
    }
}

extension Captures: Equatable {
    static func ==(lhs: Captures, rhs: Captures) -> Bool {
        return lhs.captures.count == rhs.captures.count && !zip(lhs.captures, rhs.captures).contains(where: { $0 != $1 })
    }
}

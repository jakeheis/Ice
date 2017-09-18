//
//  Captures.swift
//  Exec
//
//  Created by Jake Heiser on 9/17/17.
//

public protocol Capturable {
    static func fromCapture(_ text: String) -> Self?
}

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

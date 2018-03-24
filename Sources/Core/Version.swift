//
//  Version.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI

public struct Version {
    
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    public var raw: String {
        return description
    }
    
    public init?(_ str: String) {
        var versionString = str
        if versionString.hasPrefix("v") {
            versionString = String(versionString[versionString.index(after: versionString.startIndex)...])
        }
        let split = versionString.components(separatedBy: ".")
        if split.count != 3 {
            return nil
        }
        guard let major = Int(split[0]), let minor = Int(split[1]), let patch = Int(split[2]) else {
            return nil
        }
        
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
}

extension Version: Comparable {
    public static func <(lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        if lhs.patch != rhs.patch {
            return lhs.patch < rhs.patch
        }
        return false
    }
    
    public static func ==(lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}

extension Version: ConvertibleFromString {
    public static func convert(from: String) -> Version? {
        return Version(from)
    }
}


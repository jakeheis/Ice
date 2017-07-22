//
//  Version.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

struct Version {
    let major: Int
    let minor: Int
    let patch: String
    init?(_ str: String) {
        let split = str.components(separatedBy: ".")
        if split.count != 3 {
            return nil
        }
        let majorStr: String
        if split[0].hasPrefix("v") {
            majorStr = split[0].substring(from: split[0].index(after: split[0].startIndex))
        } else {
            majorStr = split[0]
        }
        guard let major = Int(majorStr),
            let minor = Int(split[1]) else {
                return nil
        }
        self.major = major
        self.minor = minor
        self.patch = split[2]
    }
}

extension Version: Comparable {
    static func <(lhs: Version, rhs: Version) -> Bool {
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
    
    static func ==(lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

extension Version: CustomStringConvertible {
    
    var description: String {
        return "\(major).\(minor).\(patch)"
    }
    
}


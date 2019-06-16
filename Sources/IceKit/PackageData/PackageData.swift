//
//  PackageData.swift
//  IceKit
//
//  Created by Jake Heiser on 7/29/18.
//

public typealias ModernPackageData = PackageDataV5_0

// MARK: - Tools

public struct SwiftToolsVersion {
    
    public static let v4 = SwiftToolsVersion(major: 4, minor: 0, patch: 0)
    public static let v4_2 = SwiftToolsVersion(major: 4, minor: 2, patch: 0)
    public static let v5 = SwiftToolsVersion(major: 5, minor: 0, patch: 0)
    
    public let version: Version
    
    public init(major: Int, minor: Int, patch: Int?) {
        self.version = Version(major, minor, patch ?? 0)
    }
    
    public init?(_ str: String) {
        let split = str.components(separatedBy: ".")
        guard split.count == 2 || split.count == 3 else {
            return nil
        }
        guard let major = Int(split[0]), let minor = Int(split[1]) else {
            return nil
        }
        if split.count == 3 {
            guard let patch = Int(split[2]) else {
                return nil
            }
            self.init(major: major, minor: minor, patch: patch)
        } else {
            self.init(major: major, minor: minor, patch: nil)
        }
    }
    
}

extension SwiftToolsVersion: Comparable {
    public static func <(lhs: SwiftToolsVersion, rhs: SwiftToolsVersion) -> Bool {
        return lhs.version < rhs.version
    }
    
    public static func ==(lhs: SwiftToolsVersion, rhs: SwiftToolsVersion) -> Bool {
        return lhs.version == rhs.version
    }
}

extension SwiftToolsVersion: CustomStringConvertible {
    public var description: String {
        if version.patch == 0 {
            return "\(version.major).\(version.minor)"
        } else {
            return version.description
        }
    }
}

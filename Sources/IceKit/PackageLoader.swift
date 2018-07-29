//
//  PackageLoader.swift
//  IceKit
//
//  Created by Jake Heiser on 7/28/18.
//

import Foundation
import PathKit
import Regex
import SwiftCLI

struct PackageLoader {
    
    private final class ToolsVersionLine: Matcher & Matchable {
        // Spec at: https://github.com/apple/swift-package-manager/blob/master/Sources/PackageLoading/ToolsVersionLoader.swift#L97
        static let regex = Regex("^// swift-tools-version:(.*?)(?:;.*|$)", options: [.ignoreCase])
        
        var toolsVersion: String { return captures[0] }
    }
    
    static func load(in path: Path) throws -> Package {
        let data = try SPM(directory: path).dumpPackage()
        
        guard let file = ReadStream(path: (path + Package.fileName).string),
            let line = file.readLine(),
            let match = ToolsVersionLine.findMatch(in: line),
            let toolsVersion = SwiftToolsVersion(match.toolsVersion) else {
                throw IceError(message: "couldn't read Package.swift")
        }
        
        return try load(from: data, directory: path, toolsVersion: toolsVersion)
    }
    
    static func load(from payload: Data, directory: Path, toolsVersion: SwiftToolsVersion) throws -> Package {
        let data: PackageV4_2
        if let v4_2 = try? JSONDecoder().decode(PackageV4_2.self, from: payload) {
            data = v4_2
        } else if let v4_0 = try? JSONDecoder().decode(PackageV4_0.self, from: payload) {
            data = v4_0.convertToModern()
        } else {
            throw IceError(message: "couldn't parse Package.swift")
        }
        return Package(data: data, directory: directory, toolsVersion: toolsVersion)
    }
    
    private init() {}

}

// MARK: - Tools

public struct SwiftToolsVersion {
    
    public static let v4 = SwiftToolsVersion(major: 4, minor: 0, patch: 0)
    public static let v4_2 = SwiftToolsVersion(major: 4, minor: 2, patch: 0)
    
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

// MARK: - Current version

public struct PackageV4_2: Decodable {
    
    public struct Provider: Decodable {
        public let name: String
        public let values: [String]
    }
    
    public struct Product: Decodable {
        public let name: String
        public let product_type: String
        public var targets: [String]
        public let type: String?
    }
    
    public struct Dependency: Decodable {
        public struct Requirement: Decodable {
            public enum RequirementType: String, Decodable {
                case range
                case branch
                case exact
                case revision
            }
            public let type: RequirementType
            public let lowerBound: String?
            public let upperBound: String?
            public let identifier: String?
            
            public init(type: RequirementType, lowerBound: String?, upperBound: String?, identifier: String?) {
                self.type = type
                self.lowerBound = lowerBound
                self.upperBound = upperBound
                self.identifier = identifier
            }
        }
        
        public let url: String
        public var requirement: Requirement
    }
    
    public struct Target: Decodable {
        public struct Dependency: Decodable {
            public let name: String
        }
        
        public let name: String
        public let isTest: Bool
        public var dependencies: [Dependency]
        public let path: String?
        public let exclude: [String]
        public let sources: [String]?
        public let publicHeadersPath: String?
    }
    
    public let name: String
    public let pkgConfig: String?
    public let providers: [PackageV4_2.Provider]?
    public internal(set) var products: [PackageV4_2.Product]
    public internal(set) var dependencies: [PackageV4_2.Dependency]
    public internal(set) var targets: [PackageV4_2.Target]
    public let swiftLanguageVersions: [String]?
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?

}

extension PackageV4_2.Product {
    public var isExecutable: Bool {
        return product_type == "executable"
    }
}

extension PackageV4_2.Dependency.Requirement {
    
    public init(version: Version){
        self.init(type: .range, lowerBound: version.raw, upperBound: Version(version.major + 1, 0, 0).raw, identifier: nil)
    }
}

// MARK: - Past versions

public struct PackageV4_0: Decodable {
    
    public let name: String
    public let pkgConfig: String?
    public let providers: [PackageV4_2.Provider]?
    public let products: [PackageV4_2.Product]
    public let dependencies: [PackageV4_2.Dependency]
    public let targets: [PackageV4_2.Target]
    public let swiftLanguageVersions: [Int]? // Changed
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    
    func convertToModern() -> PackageV4_2 {
        let newSwiftLanguageVersions: [String]?
        if let swiftLanguageVersions = swiftLanguageVersions {
            newSwiftLanguageVersions = swiftLanguageVersions.map(String.init)
        } else {
            newSwiftLanguageVersions = nil
        }
        return PackageV4_2(
            name: name,
            pkgConfig: pkgConfig,
            providers: providers,
            products: products,
            dependencies: dependencies,
            targets: targets,
            swiftLanguageVersions: newSwiftLanguageVersions,
            cLanguageStandard: cLanguageStandard,
            cxxLanguageStandard: cxxLanguageStandard
        )
    }
    
}

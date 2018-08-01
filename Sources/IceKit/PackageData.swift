//
//  PackageData.swift
//  IceKit
//
//  Created by Jake Heiser on 7/29/18.
//

public typealias ModernPackageData = PackageDataV4_2

public struct PackageDataV4_2: Codable {
    
    public struct Provider: Codable {
        public let name: String
        public let values: [String]
    }
    
    public struct Product: Codable {
        public let name: String
        public let product_type: String
        public var targets: [String]
        public let type: String?
        
        public var isExecutable: Bool {
            return product_type == "executable"
        }
    }
    
    public struct Dependency: Codable {
        public struct Requirement: Codable {
            public enum RequirementType: String, Codable {
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
            
            public init(version: Version){
                self.init(type: .range, lowerBound: version.raw, upperBound: Version(version.major + 1, 0, 0).raw, identifier: nil)
            }
        }
        
        public let url: String
        public var requirement: Requirement
        
        public var name: String {
            return RepositoryReference(url: url).name
        }
    }
    
    public struct Target: Codable {
        public struct Dependency: Codable {
            public let name: String
        }
        
        public enum TargetType: String, Codable {
            case regular
            case test
        }
        
        public let name: String
        public let type: TargetType
        public var dependencies: [Dependency]
        public let path: String?
        public let exclude: [String]
        public let sources: [String]?
        public let publicHeadersPath: String?
    }
    
    public let name: String
    public let pkgConfig: String?
    public let providers: [PackageDataV4_2.Provider]?
    public internal(set) var products: [PackageDataV4_2.Product]
    public internal(set) var dependencies: [PackageDataV4_2.Dependency]
    public internal(set) var targets: [PackageDataV4_2.Target]
    public let swiftLanguageVersions: [String]?
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    
}

public struct PackageDataV4_0: Codable {
    
    public typealias Provider = PackageDataV4_2.Provider
    public typealias Product = PackageDataV4_2.Product
    public typealias Dependency = PackageDataV4_2.Dependency
    
    public struct Target: Codable {
        public struct Dependency: Codable {
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
    public let providers: [PackageDataV4_0.Provider]?
    public let products: [PackageDataV4_0.Product]
    public let dependencies: [PackageDataV4_0.Dependency]
    public let targets: [PackageDataV4_0.Target]
    public let swiftLanguageVersions: [Int]? // Changed
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    
    func convertToModern() -> PackageDataV4_2 {
        let newSwiftLanguageVersions: [String]?
        if let swiftLanguageVersions = swiftLanguageVersions {
            newSwiftLanguageVersions = swiftLanguageVersions.map(String.init)
        } else {
            newSwiftLanguageVersions = nil
        }
        return PackageDataV4_2(
            name: name,
            pkgConfig: pkgConfig,
            providers: providers,
            products: products,
            dependencies: dependencies,
            targets: targets.map { (oldTarget) in
                return .init(
                    name: oldTarget.name,
                    type: oldTarget.isTest ? .test : .regular,
                    dependencies: oldTarget.dependencies.map({ .init(name: $0.name) }),
                    path: oldTarget.path,
                    exclude: oldTarget.exclude,
                    sources: oldTarget.sources,
                    publicHeadersPath: oldTarget.publicHeadersPath
                )
            },
            swiftLanguageVersions: newSwiftLanguageVersions,
            cLanguageStandard: cLanguageStandard,
            cxxLanguageStandard: cxxLanguageStandard
        )
    }
    
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

//
//  V5_0.swift
//  Ice
//
//  Created by Jake Heiser on 12/21/18.
//

import Foundation

public struct PackageDataV5_0: Codable {
    
    public struct Provider {
        public let name: String
        public let values: [String]
        
        public init(name: String, values: [String]) {
            self.name = name
            self.values = values
        }
    }
    
    public struct Product {
        public enum ProductType {
            public enum LibraryType: String {
                case automatic
                case `static`
                case dynamic
            }
            
            case executable
            case library(LibraryType)
        }
        
        public let name: String
        public var targets: [String]
        public let type: ProductType
        
        public init(name: String, targets: [String], type: ProductType) {
            self.name = name
            self.targets = targets
            self.type = type
        }
    }
    
    public struct Dependency {
        
        public enum Requirement {
            case range(String, String)
            case branch(String)
            case exact(String)
            case revision(String)
            case localPackage
        }
        
        public let url: String
        public var requirement: Requirement
        
        public var name: String {
            return RepositoryReference(url: url).name
        }
        
        public init(url: String, requirement: Requirement) {
            self.url = url
            self.requirement = requirement
        }
        
    }
    
    public struct Target: Codable {
        public enum Dependency {
            case target(String)
            case product(String, String?)
            case byName(String)
            
            var name: String {
                switch self {
                case let .target(name), let .product(name, _), let .byName(name):
                    return name
                }
            }
        }
        
        public enum TargetType: String, Codable {
            case regular
            case test
            case system
        }
        
        public let name: String
        public let type: TargetType
        public var dependencies: [Dependency]
        public let path: String?
        public let exclude: [String]
        public let sources: [String]?
        public let publicHeadersPath: String?
        public let pkgConfig: String?
        public let providers: [Provider]?
        
        public init(name: String, type: TargetType, dependencies: [Dependency], path: String?, exclude: [String], sources: [String]?, publicHeadersPath: String?, pkgConfig: String?, providers: [Provider]?) {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.path = path
            self.exclude = exclude
            self.sources = sources
            self.publicHeadersPath = publicHeadersPath
            self.pkgConfig = pkgConfig
            self.providers = providers
        }
    }
    
    public let name: String
    public let pkgConfig: String?
    public let providers: [PackageDataV5_0.Provider]?
    public internal(set) var products: [PackageDataV5_0.Product]
    public internal(set) var dependencies: [PackageDataV5_0.Dependency]
    public internal(set) var targets: [PackageDataV5_0.Target]
    public internal(set) var swiftLanguageVersions: [String]?
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    
}

extension PackageDataV5_0.Provider: Codable {
    
    enum CodingKeys: String, CodingKey {
        case apt
        case brew
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let values = try? container.decode([[String]].self, forKey: .apt) {
            self.name = CodingKeys.apt.rawValue
            self.values = Array(values.joined())
        } else if let values = try? container.decode([[String]].self, forKey: .brew) {
            self.name = CodingKeys.brew.rawValue
            self.values = Array(values.joined())
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "providers type not recognized"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
}

extension PackageDataV5_0.Product: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case targets
        case type
    }
    
    public enum ProductTypeCodingKeys: String, CodingKey {
        case executable
        case library
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.targets = try container.decode([String].self, forKey: .targets)
        
        let type = try container.nestedContainer(keyedBy: ProductTypeCodingKeys.self, forKey: .type)
        if let library = try? type.decode([String].self, forKey: .library), !library.isEmpty, let libType = ProductType.LibraryType(rawValue: library[0]) {
            self.type = .library(libType)
        } else if type.contains(.executable) {
            self.type = .executable
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "product type not recognized"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
}

extension PackageDataV5_0.Dependency: Codable {}

extension PackageDataV5_0.Dependency.Requirement: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case range
        case branch
        case exact
        case revision
        case localPackage
    }
    
    private struct RequirementRange: Codable {
        let lowerBound: String
        let upperBound: String
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let ranges = try? container.decode([RequirementRange].self, forKey: .range), let range = ranges.first {
            self = .range(range.lowerBound, range.upperBound)
        } else if let branch = try? container.decode(String.self, forKey: .branch) {
            self = .branch(branch)
        } else if let exact = try? container.decode(String.self, forKey: .exact) {
            self = .exact(exact)
        } else if let revision = try? container.decode(String.self, forKey: .revision) {
            self = .revision(revision)
        } else if container.contains(.localPackage) {
            self = .localPackage
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "requirement type not recognized"))
        }
    }
    
    public init(version: Version) {
        self = .range(version.string, Version(version.major + 1, 0, 0).string)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .range(_, _):
            break
            //                    var rangeContainer = container.nestedContainer(keyedBy: Range.CodingKeys.self, forKey: .range)
            //                    try rangeContainer.encode(lower, forKey: .lowerBound)
        //                    try rangeContainer.encode(upper, forKey: .upperBound)
        case let .branch(branch):
            try container.encode(branch, forKey: .branch)
        case let .exact(exact):
            try container.encode(exact, forKey: .exact)
        case let .revision(revision):
            try container.encode(revision, forKey: .revision)
        case .localPackage:
            try container.encodeNil(forKey: .localPackage)
        }
    }
    
}

extension PackageDataV5_0.Target.Dependency: Codable {
    
    enum CodingKeys: String, CodingKey {
        case target
        case product
        case byName
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let targets = try? container.decode([String].self, forKey: .target), let target = targets.first {
            self = .target(target)
        } else if let products = try? container.decode([String].self, forKey: .product), let product = products.first {
            let package = products.count > 1 ? products[1] : nil
            self = .product(product, package)
        } else if let byNames = try? container.decode([String].self, forKey: .byName), let byName = byNames.first {
            self = .byName(byName)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "target dependency type not recognized"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
}

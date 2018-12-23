//
//  V5_0.swift
//  Ice
//
//  Created by Jake Heiser on 12/21/18.
//

public struct PackageDataV5_0: Codable, Equatable {
    
    public struct Provider: Equatable {
        public enum Kind: String, CodingKey {
            case apt
            case brew
        }
        
        public let kind: Kind
        public let values: [String]
        
        public init(kind: Kind, values: [String]) {
            self.kind = kind
            self.values = values
        }
    }
    
    public struct Product: Equatable {
        public enum ProductType: Equatable {
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
    
    public struct Dependency: Equatable {
        
        public enum Requirement: Equatable {
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
    
    public struct Target: Codable, Equatable {
        public enum Dependency: Equatable {
            case target(String)
            case product(String, String?)
            case byName(String)
            
            var targetName: String? {
                switch self {
                case let .target(target), let .byName(target): return target
                case .product(_, _): return nil
                }
            }
            
            var packageName: String? {
                switch self {
                case let .product(product, package): return package ?? product
                case let .byName(package): return package
                case .target(_): return nil
                }
            }
        }
        
        public enum TargetType: String, Codable {
            case regular
            case test
            case system
        }
        
        public struct Setting: Codable, Equatable {
            public struct Condition: Codable, Equatable {
                public let config: String?
                public let platformNames: [String]
                
                public init(config: String? = nil, platformNames: [String] = []) {
                    self.config = config
                    self.platformNames = platformNames
                }
            }
            
            public enum Tool: String, Codable {
                case c
                case cxx
                case swift
                case linker
            }
            
            public let name: String
            public let tool: Tool
            public let condition: Condition?
            public let value: [String]
            
            public init(name: String, tool: Tool, condition: Condition?, value: [String]) {
                self.name = name
                self.tool = tool
                self.condition = condition
                self.value = value
            }
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
        public let settings: [Setting]
        
        public init(name: String, type: TargetType, dependencies: [Dependency], path: String? = nil, exclude: [String] = [], sources: [String]? = nil, publicHeadersPath: String? = nil, pkgConfig: String? = nil, providers: [Provider]? = nil, settings: [Setting] = []) {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.path = path
            self.exclude = exclude
            self.sources = sources
            self.publicHeadersPath = publicHeadersPath
            self.pkgConfig = pkgConfig
            self.providers = providers
            self.settings = settings
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

// MARK: - Codable

extension PackageDataV5_0.Provider: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Kind.self)
        if let values = try? container.decode([[String]].self, forKey: .apt) {
            self.kind = .apt
            self.values = Array(values.joined())
        } else if let values = try? container.decode([[String]].self, forKey: .brew) {
            self.kind = .brew
            self.values = Array(values.joined())
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "providers type not recognized"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Kind.self)
        try container.encode([values], forKey: kind)
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
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "product type not recognized"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(targets, forKey: .targets)
        
        var typeContainer = container.nestedContainer(keyedBy: ProductTypeCodingKeys.self, forKey: .type)
        switch type {
        case .executable:
            try typeContainer.encodeNil(forKey: .executable)
        case let .library(libType):
            try typeContainer.encode([libType.rawValue], forKey: .library)
        }
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
        } else if let branchArray = try? container.decode([String].self, forKey: .branch), let branch = branchArray.first {
            self = .branch(branch)
        } else if let exactArray = try? container.decode([String].self, forKey: .exact), let exact = exactArray.first {
            self = .exact(exact)
        } else if let revisionArray = try? container.decode([String].self, forKey: .revision), let revision = revisionArray.first {
            self = .revision(revision)
        } else if container.contains(.localPackage) {
            self = .localPackage
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "requirement type not recognized"))
        }
    }
    
    public init(version: Version) {
        self = .range(version.string, Version(version.major + 1, 0, 0).string)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .range(lower, upper):
            try container.encode([RequirementRange(lowerBound: lower, upperBound: upper)], forKey: .range)
        case let .branch(branch):
            try container.encode([branch], forKey: .branch)
        case let .exact(exact):
            try container.encode([exact], forKey: .exact)
        case let .revision(revision):
            try container.encode([revision], forKey: .revision)
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
        } else if let products = try? container.decode([String?].self, forKey: .product), let firstProduct = products.first, let product = firstProduct {
            let package = products.count > 1 ? products[1] : nil
            self = .product(product, package)
        } else if let byNames = try? container.decode([String].self, forKey: .byName), let byName = byNames.first {
            self = .byName(byName)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "target dependency type not recognized"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .byName(name):
            try container.encode([name], forKey: .byName)
        case let .product(product, package):
            try container.encode([product, package], forKey: .product)
        case let .target(target):
            try container.encode([target], forKey: .target)
        }
    }
    
}

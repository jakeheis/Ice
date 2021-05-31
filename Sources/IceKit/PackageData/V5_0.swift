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
        
        public static func ==(lhs: Provider, rhs: Provider) -> Bool {
            return lhs.kind == rhs.kind && lhs.values == rhs.values
        }
        
        public let kind: Kind
        public let values: [String]
        
        public init(kind: Kind, values: [String]) {
            self.kind = kind
            self.values = values
        }
    }
    
    public struct Platform: Codable, Equatable {
        
        public enum Name: String, Codable, Equatable {
            case macos
            case ios
            case tvos
            case watchos
            case linux
            
            var functionName: String {
                // macos -> macOS
                return rawValue.replacingOccurrences(of: "os", with: "OS")
            }
        }
        
        public static func ==(lhs: Platform, rhs: Platform) -> Bool {
            return lhs.platformName == rhs.platformName && lhs.version == rhs.version
        }
        
        public let platformName: Name
        public let version: String
        
        init(platformName: Name, version: String) {
            self.platformName = platformName
            self.version = version
        }
    }
    
    public struct Product: Equatable {
        public enum ProductType {
            public enum LibraryType: String {
                case automatic
                case `static`
                case dynamic
            }
            
            case executable
            case library(LibraryType)
        }
        
        public static func ==(lhs: Product, rhs: Product) -> Bool {
            guard lhs.name == rhs.name, lhs.targets == rhs.targets else {
                return false
            }
            switch (lhs.type, rhs.type) {
            case (.executable, .executable): return true
            case let (.library(t1), .library(t2)) where t1 == t2: return true
            default: return false
            }
        }
        
        public let name: String
        public var targets: [String]
        public let type: ProductType
        
        init(name: String, targets: [String], type: ProductType) {
            self.name = name
            self.targets = targets
            self.type = type
        }
    }
    
    public struct Dependency: Codable, Equatable {
        
        public enum Requirement: Equatable {
            case range(String, String)
            case branch(String)
            case exact(String)
            case revision(String)
            case localPackage
            
            public static func ==(lhs: Requirement, rhs: Requirement) -> Bool {
                switch (lhs, rhs) {
                case let (.range(l1, u1), .range(l2, u2)) where l1 == l2 && u1 == u2 : return true
                case let (.branch(b1), .branch(b2)) where b1 == b2: return true
                case let (.exact(e1), .exact(e2)) where e1 == e2: return true
                case let (.revision(r1), .revision(r2)) where r1 == r2: return true
                case (.localPackage, .localPackage): return true
                default: return false
                }
            }
        }
        
        public static func ==(lhs: Dependency, rhs: Dependency) -> Bool {
            return lhs.url == rhs.url && lhs.requirement == rhs.requirement
        }
        
        public let url: String
        public var requirement: Requirement
        
        public var name: String {
            return RepositoryReference(url: url).name
        }
        
        init(url: String, requirement: Requirement) {
            self.url = url
            self.requirement = requirement
        }
        
    }
    
    public struct Target: Codable, Equatable {
        public enum Dependency: Equatable {
            case target(String)
            case product(String, String?)
            case byName(String)
            
            public static func ==(lhs: Dependency, rhs: Dependency) -> Bool {
                switch (lhs, rhs) {
                case let (.target(t1), .target(t2)) where t1 == t2: return true
                case let (.product(prod1, pac1), .product(prod2, pac2)) where prod1 == prod2 && pac1 == pac2: return true
                case let (.byName(n1), .byName(n2)) where n1 == n2: return true
                default: return false
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
                public let platformNames: [Platform.Name]
                
                public static func ==(lhs: Condition, rhs: Condition) -> Bool {
                    return lhs.config == rhs.config && lhs.platformNames == rhs.platformNames
                }
                
                public init(config: String? = nil, platformNames: [Platform.Name] = []) {
                    self.config = config
                    self.platformNames = platformNames
                }
            }
            
            public static func ==(lhs: Setting, rhs: Setting) -> Bool {
                return lhs.name == rhs.name && lhs.tool == rhs.tool && lhs.condition == rhs.condition && lhs.value == rhs.value
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
            
            init(name: String, tool: Tool, condition: Condition?, value: [String]) {
                self.name = name
                self.tool = tool
                self.condition = condition
                self.value = value
            }
        }
        
        public static func ==(lhs: Target, rhs: Target) -> Bool {
            guard lhs.name == rhs.name, lhs.type == rhs.type, lhs.dependencies == rhs.dependencies, lhs.path == rhs.path, lhs.exclude == rhs.exclude,
                lhs.sources ?? [] == rhs.sources ?? [], lhs.publicHeadersPath == rhs.publicHeadersPath, lhs.pkgConfig == rhs.pkgConfig,
                lhs.providers ?? [] == rhs.providers ?? [], lhs.settings == rhs.settings else {
                return false
            }
            for (ld, rd) in zip(lhs.dependencies, rhs.dependencies) {
                switch (ld, rd) {
                case let (.target(t1), .target(t2)) where t1 == t2: continue
                case let (.product(prod1, pac1), .product(prod2, pac2)) where prod1 == prod2 && pac1 == pac2: continue
                case let (.byName(n1), .byName(n2)) where n1 == n2: continue
                default: return false
                }
            }
            return true
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
        
        init(name: String, type: TargetType, dependencies: [Dependency], path: String? = nil, exclude: [String] = [], sources: [String]? = nil, publicHeadersPath: String? = nil, pkgConfig: String? = nil, providers: [Provider]? = nil, settings: [Setting] = []) {
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
    
    public static func ==(lhs: PackageDataV5_0, rhs: PackageDataV5_0) -> Bool {
        return lhs.name == rhs.name && lhs.platforms == rhs.platforms && lhs.pkgConfig == rhs.pkgConfig && lhs.providers ?? [] == rhs.providers ?? [] && lhs.products == rhs.products && lhs.dependencies == rhs.dependencies && lhs.targets == rhs.targets && lhs.swiftLanguageVersions ?? [] == rhs.swiftLanguageVersions ?? [] && lhs.cLanguageStandard == rhs.cLanguageStandard && lhs.cxxLanguageStandard == rhs.cxxLanguageStandard
    }
    
    public let name: String
    public internal(set) var platforms: [Platform]
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
    
    public init(from version: Version) {
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
        if let targets = try? container.decode([String?].self, forKey: .target), let targetWrapped = targets.first, let target = targetWrapped {
            self = .target(target)
        } else if let products = try? container.decode([String?].self, forKey: .product), let productWrapped = products.first, let product = productWrapped {
            let package = products.count > 1 ? products[1] : nil
            self = .product(product, package)
        } else if let byNames = try? container.decode([String?].self, forKey: .byName), let byNameWrapped = byNames.first, let byName = byNameWrapped {
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

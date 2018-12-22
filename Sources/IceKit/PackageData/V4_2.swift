//
//  V4_2.swift
//  Ice
//
//  Created by Jake Heiser on 12/21/18.
//

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
                case localPackage
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
            
            public init(version: Version) {
                self.init(type: .range, lowerBound: version.string, upperBound: Version(version.major + 1, 0, 0).string, identifier: nil)
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
            public enum DependencyType: String, Codable {
                case byname
                case target
                case product
            }
            
            public let name: String
            public let package: String?
            public let type: DependencyType
        }
        
        public typealias TargetType = PackageDataV5_0.Target.TargetType
        
        public let name: String
        public let type: TargetType
        public var dependencies: [Dependency]
        public let path: String?
        public let exclude: [String]
        public let sources: [String]?
        public let publicHeadersPath: String?
        public let pkgConfig: String?
        public let providers: [Provider]?
    }
    
    public let name: String
    public let pkgConfig: String?
    public let providers: [Provider]?
    public internal(set) var products: [Product]
    public internal(set) var dependencies: [Dependency]
    public internal(set) var targets: [Target]
    public internal(set) var swiftLanguageVersions: [String]?
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    
    func convertToModern() -> ModernPackageData {
        return PackageDataV5_0(
            name: name,
            pkgConfig: pkgConfig,
            providers: providers?.map { (oldProvider) in
                return .init(name: oldProvider.name, values: oldProvider.values)
            },
            products: products.map { (oldProduct) in
                let type: PackageDataV5_0.Product.ProductType
                if oldProduct.product_type == "executable" {
                    type = .executable
                } else {
                    let libType: PackageDataV5_0.Product.ProductType.LibraryType
                    if oldProduct.type == "dynamic" {
                        libType = .dynamic
                    } else if oldProduct.type == "static" {
                        libType = .static
                    } else {
                        libType = .automatic
                    }
                    type = .library(libType)
                }
                return .init(
                    name: oldProduct.name,
                    targets: oldProduct.targets,
                    type: type
                )
            },
            dependencies: dependencies.map { (oldDependency) in
                let requirement: PackageDataV5_0.Dependency.Requirement
                switch oldDependency.requirement.type {
                case .range:
                    requirement = .range(oldDependency.requirement.lowerBound!, oldDependency.requirement.upperBound!)
                case .branch:
                    requirement = .branch(oldDependency.requirement.identifier!)
                case .exact:
                    requirement = .exact(oldDependency.requirement.identifier!)
                case .revision:
                    requirement = .revision(oldDependency.requirement.identifier!)
                case .localPackage:
                    requirement = .localPackage
                }
                return .init(
                    url: oldDependency.url,
                    requirement: requirement
                )
            },
            targets: targets.map { (target) in
                return .init(
                    name: target.name,
                    type: target.type,
                    dependencies: target.dependencies.map { (oldDep) in
                        switch oldDep.type {
                        case .byname:
                            return .byName(oldDep.name)
                        case .product:
                            return .product(oldDep.name, oldDep.package)
                        case .target:
                            return .target(oldDep.name)
                        }
                    },
                    path: target.path,
                    exclude: target.exclude,
                    sources: target.sources,
                    publicHeadersPath: target.publicHeadersPath,
                    pkgConfig: target.pkgConfig,
                    providers: target.providers?.map { (oldProvider) in
                        return .init(name: oldProvider.name, values: oldProvider.values)
                    }
                )
            },
            swiftLanguageVersions: swiftLanguageVersions,
            cLanguageStandard: cLanguageStandard,
            cxxLanguageStandard: cxxLanguageStandard
        )
    }
    
}


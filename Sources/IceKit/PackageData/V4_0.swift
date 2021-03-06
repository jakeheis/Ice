//
//  V4_0.swift
//  Ice
//
//  Created by Jake Heiser on 12/21/18.
//

public struct PackageDataV4_0: Codable {
    
    public typealias Provider = PackageDataV4_2.Provider
    public typealias Product = PackageDataV4_2.Product
    
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
        }
        
        public let url: String
        public var requirement: Requirement
        
        public var name: String {
            return RepositoryReference(url: url).name
        }
    }
    
    public struct Target: Codable {
        public typealias Dependency = PackageDataV4_2.Target.Dependency
        
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
    public let providers: [Provider]?
    public let products: [Product]
    public let dependencies: [Dependency]
    public let targets: [Target]
    public let swiftLanguageVersions: [Int]?
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    
    func convertToModern() -> ModernPackageData {
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
            dependencies: dependencies.map { (oldDependency) in
                let reqType: PackageDataV4_2.Dependency.Requirement.RequirementType
                switch oldDependency.requirement.type {
                case .branch: reqType = .branch
                case .revision: reqType = .revision
                case .exact: reqType = .exact
                case .range: reqType = .range
                }
                return .init(url: oldDependency.url, requirement: .init(type: reqType, lowerBound: oldDependency.requirement.lowerBound, upperBound: oldDependency.requirement.upperBound, identifier: oldDependency.requirement.identifier))
            },
            targets: targets.map { (oldTarget) in
                return .init(
                    name: oldTarget.name,
                    type: oldTarget.isTest ? .test : .regular,
                    dependencies: oldTarget.dependencies,
                    path: oldTarget.path,
                    exclude: oldTarget.exclude,
                    sources: oldTarget.sources,
                    publicHeadersPath: oldTarget.publicHeadersPath,
                    pkgConfig: nil,
                    providers: nil
                )
            },
            swiftLanguageVersions: newSwiftLanguageVersions,
            cLanguageStandard: cLanguageStandard,
            cxxLanguageStandard: cxxLanguageStandard
            ).convertToModern()
    }
    
}

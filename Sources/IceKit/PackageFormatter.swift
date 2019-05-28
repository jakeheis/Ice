//
//  PackageFormatter.swift
//  IceKit
//
//  Created by Jake Heiser on 7/29/18.
//

public class PackageFormatter {
    
    public let package: ModernPackageData
    
    public init(package: ModernPackageData) {
        self.package = package
    }
    
    public func format() -> ModernPackageData {
        return ModernPackageData(
            name: package.name,
            platforms: package.platforms?.sorted(by: sortPlatform),
            pkgConfig: package.pkgConfig,
            providers: package.providers?.map(formatProvider),
            products: package.products.map(formatProduct).sorted(by: sortProduct),
            dependencies: package.dependencies.sorted(by: sortDependency),
            targets: package.targets.map(formatTarget).sorted(by: sortTarget),
            swiftLanguageVersions: package.swiftLanguageVersions?.sorted(),
            cLanguageStandard: package.cLanguageStandard,
            cxxLanguageStandard: package.cxxLanguageStandard
        )
    }
    
    func sortPlatform(lhs: ModernPackageData.Platform, rhs: ModernPackageData.Platform) -> Bool {
        return lhs.platformName.rawValue < rhs.platformName.rawValue
    }
    
    func formatProvider(provider: Package.Provider) -> Package.Provider {
        return .init(
            kind: provider.kind,
            values: provider.values.sorted()
        )
    }
    
    func formatProduct(product: Package.Product) -> Package.Product {
        return .init(
            name: product.name,
            targets: product.targets.sorted(),
            type: product.type
        )
    }
    
    func sortProduct(lhs: Package.Product, rhs: Package.Product) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.executable, .library(_)):
            return true
        case (.library(_), .executable):
            return false
        default: return lhs.name < rhs.name
        }
    }
    
    func sortDependency(lhs: Package.Dependency, rhs: Package.Dependency) -> Bool {
        return RepositoryReference(url: lhs.url).name < RepositoryReference(url: rhs.url).name
    }
    
    func formatTarget(target: Package.Target) -> Package.Target {
        return .init(
            name: target.name,
            type: target.type,
            dependencies: target.dependencies.sorted { (lhs, rhs) in
                let lName: String
                switch lhs {
                case let .target(name): lName = name
                case let .product(name, _): lName = name
                case let .byName(name): lName = name
                }
                let rName: String
                switch rhs {
                case let .target(name): rName = name
                case let .product(name, _): rName = name
                case let .byName(name): rName = name
                }
                return lName < rName
            },
            path: target.path,
            exclude: target.exclude.sorted(),
            sources: target.sources?.sorted(),
            publicHeadersPath: target.publicHeadersPath,
            pkgConfig: target.pkgConfig,
            providers: target.providers,
            settings: target.settings
        )
    }
    
    func sortTarget(lhs: Package.Target, rhs: Package.Target) -> Bool {
        if lhs.type == rhs.type {
            return lhs.name < rhs.name
        }
        
        switch (lhs.type, rhs.type) {
        case (.system, _): return true
        case (_, .system): return false
        case (.regular, _): return true
        case (_, .regular): return false
        default: return lhs.name < rhs.name
        }
    }
    
}

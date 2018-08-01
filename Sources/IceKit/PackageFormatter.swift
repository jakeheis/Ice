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
            pkgConfig: package.pkgConfig,
            providers: package.providers?.map(formatProvider),
            products: package.products.map(formatProduct).sorted(by: sortProduct),
            dependencies: package.dependencies.sorted(by: sortDependency),
            targets: package.targets.map(formatTarget).sorted(by: sortPackage),
            swiftLanguageVersions: package.swiftLanguageVersions?.sorted(),
            cLanguageStandard: package.cLanguageStandard,
            cxxLanguageStandard: package.cxxLanguageStandard
        )
    }
    
    func formatProvider(provider: Package.Provider) -> Package.Provider {
        return .init(
            name: provider.name,
            values: provider.values.sorted()
        )
    }
    
    func formatProduct(product: Package.Product) -> Package.Product {
        return .init(
            name: product.name,
            product_type: product.product_type,
            targets: product.targets.sorted(),
            type: product.type
        )
    }
    
    func sortProduct(lhs: Package.Product, rhs: Package.Product) -> Bool {
        if lhs.isExecutable && !rhs.isExecutable { return true }
        if !lhs.isExecutable && rhs.isExecutable { return false }
        return lhs.name < rhs.name
    }
    
    func sortDependency(lhs: Package.Dependency, rhs: Package.Dependency) -> Bool {
        return RepositoryReference(url: lhs.url).name < RepositoryReference(url: rhs.url).name
    }
    
    func formatTarget(target: Package.Target) -> Package.Target {
        return .init(
            name: target.name,
            type: target.type,
            dependencies: target.dependencies.sorted { $0.name < $1.name },
            path: target.path,
            exclude: target.exclude.sorted(),
            sources: target.sources?.sorted(),
            publicHeadersPath: target.publicHeadersPath
        )
    }
    
    func sortPackage(lhs: Package.Target, rhs: Package.Target) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.test, .regular): return false
        case (.regular, .test): return true
        default: return lhs.name < rhs.name
        }
    }
    
}

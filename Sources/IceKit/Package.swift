//
//  Package.swift
//  Core
//
//  Created by Jake Heiser on 8/27/17.
//

import Foundation
import PathKit
import SwiftCLI

public struct Package {
    
    public typealias Provider = ModernPackageData.Provider
    public typealias Product = ModernPackageData.Product
    public typealias Dependency = ModernPackageData.Dependency
    public typealias Target = ModernPackageData.Target
    
    private static let libRegex = Regex("\\.library\\( *name: *\"([^\"]*)\"")
    
    public static func load(directory: Path, config: Config? = nil) throws -> Package {
        guard let file = PackageFile.find(in: directory) else {
            throw IceError(message: "couldn't find Package.swift")
        }
        return try file.load(with: config)
    }
    
    internal private(set) var data: ModernPackageData {
        didSet {
            dirty = true
        }
    }
    
    public var name: String {
        return data.name
    }
    
    public var products: [Product] {
        return data.products
    }
    
    public var dependencies: [Dependency] {
        return data.dependencies
    }
    
    public var targets: [Target] {
        return data.targets
    }
    
    public var toolsVersion: SwiftToolsVersion {
        didSet {
            dirty = true
        }
    }
    
    public var path: Path {
        didSet {
            dirty = true
        }
    }
    
    public let config: Config
    
    public var dirty = false
    
    public init(data: ModernPackageData, toolsVersion: SwiftToolsVersion, path: Path, config: Config?) {
        self.data = data
        self.toolsVersion = toolsVersion
        self.path = path
        self.config = config ?? Config()
        
        Logger.verbose <<< "Parsed package: \(data.name)"
    }
    
    // MARK: - Products
    
    @discardableResult
    public mutating func addProduct(name: String, targets: [String], type: Product.ProductType) -> Product {
        let product = Product(name: name, targets: targets, type: type)
        data.products.append(product)
        return product
    }
    
    public func getProduct(named: String) -> Product? {
        return data.products.first(where: { $0.name == named })
    }
    
    public mutating func removeProduct(_ product: Product) {
        guard let index = data.products.firstIndex(of: product) else {
            return
        }
        data.products.remove(at: index)
    }
    
    // MARK: - Dependencies
    
    @discardableResult
    public mutating func addDependency(url: String, requirement: Dependency.Requirement) -> Dependency {
        let dependency = Dependency(url: url, requirement: requirement)
        data.dependencies.append(dependency)
        return dependency
    }
    
    public func getDependency(named: String) -> Dependency? {
        return data.dependencies.first(where: { $0.name == named })
    }
    
    public mutating func updateDependency(dependency: Dependency, to requirement: Dependency.Requirement) throws {
        guard let index = data.dependencies.firstIndex(of: dependency) else {
            throw IceError(message: "dependency '\(dependency.name)' not found")
        }
        data.dependencies[index].requirement = requirement
    }
    
    public mutating func removeDependency(_ dependency: Dependency) {
        guard let index = data.dependencies.firstIndex(of: dependency) else {
            return
        }
        
        data.dependencies.remove(at: index)
        
        let libs = retrieveLibraries(ofDependency: dependency)
        
        removeTargetDependency {
            switch $0 {
            case let .byName(lib) where libs.contains(lib): return true
            case let .product(_, package) where package == dependency.name: return true
            case let .product(lib, nil) where libs.contains(lib): return true
            default: return false
            }
        }
    }
    
    // MARK: - Targets
    
    @discardableResult
    public mutating func addTarget(name: String, type: Target.TargetType, dependencies: [Target.Dependency], path: String? = nil, exclude: [String] = [], sources: [String]? = nil, publicHeadersPath: String? = nil, pkgConfig: String? = nil, providers: [Provider]? = nil, settings: [Target.Setting] = []) -> Target {
        let target = Target(name: name, type: type, dependencies: dependencies, path: path, exclude: exclude, sources: sources, publicHeadersPath: publicHeadersPath, pkgConfig: pkgConfig, providers: providers, settings: settings)
        data.targets.append(target)
        return target
    }
    
    public func getTarget(named: String) -> Target? {
        return data.targets.first(where: { $0.name == named })
    }
    
    public mutating func addTargetDependency(for target: Target, on dependency: Package.Target.Dependency) throws {
        guard let targetIndex = data.targets.firstIndex(of: target) else {
            throw IceError(message: "target '\(target)' not found")
        }
        if data.targets[targetIndex].dependencies.contains(dependency) {
            return
        }
        data.targets[targetIndex].dependencies.append(dependency)
    }
    
    public mutating func removeTarget(_ target: Target) {
        guard let index = data.targets.firstIndex(of: target) else {
            return
        }

        data.targets.remove(at: index)
        
        removeTargetDependency(where: { $0 == .byName(target.name) || $0 == .target(target.name) })
        
        data.products = data.products.map { (oldProduct) in
            var newProduct = oldProduct
            newProduct.targets = newProduct.targets.filter { $0 != name }
            return newProduct
        }
    }
    
    // MARK: - Helpers
    
    private mutating func removeTargetDependency(where test: (Target.Dependency) -> Bool) {
        data.targets = data.targets.map { (oldTarget) in
            var newTarget = oldTarget
            newTarget.dependencies = newTarget.dependencies.filter { !test($0) }
            return newTarget
        }
    }
    
    // MARK: -
    
    public func checkoutDirectories(forDependency dependency: Dependency) -> [Path] {
        return (path.parent() + ".build" + "checkouts").glob("\(dependency.name)*")
    }
    
    public func retrieveLibraries(ofDependency dependency: Dependency) -> [String] {
        let glob = checkoutDirectories(forDependency: dependency)
        
        guard let dependencyDirectory = glob.first,
            let packageFile = PackageFile(directory: dependencyDirectory, compilerVersion: toolsVersion) else {
                return [dependency.name]
        }
        let matches = Package.libRegex.allMatches(in: packageFile.content.replacingOccurrences(of: "\n", with: " "))
        
        var libs = matches.compactMap { $0.captures[0] }
        if libs.isEmpty {
            libs.append(dependency.name)
        }
        return libs
    }
    
    public mutating func sync(format: Bool? = nil) throws {
        if !dirty {
            Logger.verbose <<< "package not dirty, sync complete"
            return
        }
        
        guard let fileStream = WriteStream.for(path: path.string, appending: false) else  {
            throw IceError(message: "couldn't write to \(path)")
        }
        Logger.verbose <<< "syncing package to \(path.string)"
        try write(to: fileStream, format: format)
        fileStream.truncateRemaining()
        dirty = false
    }
    
    public func write(to stream: WritableStream, format: Bool? = nil) throws {
        let shouldFormat = format ?? config.reformat
        Logger.verbose <<< "writing \(shouldFormat ? "" : "non-")formatted package"
        let packageData = shouldFormat ? PackageFormatter(package: data).format() : data
        let writer = try PackageWriter(package: packageData, toolsVersion: toolsVersion)
        try writer.write(to: stream)
    }
    
}

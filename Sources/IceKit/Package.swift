//
//  Package.swift
//  Core
//
//  Created by Jake Heiser on 8/27/17.
//

import Foundation
import PathKit
import Regex
import SwiftCLI

public struct Package {
    
    public typealias Provider = ModernPackageData.Provider
    public typealias Product = ModernPackageData.Product
    public typealias Dependency = ModernPackageData.Dependency
    public typealias Target = ModernPackageData.Target
    
    public static let fileName = Path("Package.swift")
    private static let libRegex = Regex("\\.library\\( *name: *\"([^\"]*)\"")
    
    public static func load(config: Config) throws -> Package {
        return try PackageLoader.load(config: config)
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
    
    private(set) var data: ModernPackageData {
        didSet {
            dirty = true
        }
    }
    
    public let config: ConfigType
    public var toolsVersion: SwiftToolsVersion {
        didSet {
            dirty = true
        }
    }
    public var dirty = false
    
    init(data: ModernPackageData, toolsVersion: SwiftToolsVersion, config: ConfigType) {
        self.data = data
        self.toolsVersion = toolsVersion
        self.config = config
    }
    
    // MARK: - Products
    
    public enum ProductType {
        case executable
        case library
        case staticLibrary
        case dynamicLibrary
    }
    
    public mutating func addProduct(name: String, type: ProductType, targets: [String]) {
        let productType: String
        switch type {
        case .executable: productType = "executable"
        case .library, .staticLibrary, .dynamicLibrary: productType = "library"
        }
        let libraryType: String?
        switch type {
        case .staticLibrary: libraryType = "static"
        case .dynamicLibrary: libraryType = "dynamic"
        case .library, .executable: libraryType = nil
        }
        data.products.append(.init(
            name: name,
            product_type: productType,
            targets: targets,
            type: libraryType)
        )
    }
    
    public mutating func removeProduct(name: String) throws {
        guard let index = data.products.index(where: { $0.name == name }) else {
            throw IceError(message: "can't remove product \(name)")
        }
        data.products.remove(at: index)
    }
    
    // MARK: - Dependencies
    
    public mutating func addDependency(ref: RepositoryReference, requirement: Package.Dependency.Requirement) {
        data.dependencies.append(.init(
            url: ref.url,
            requirement: requirement
        ))
    }
    
    public mutating func updateDependency(dependency: Package.Dependency, to requirement: Package.Dependency.Requirement) throws {
        guard let index = data.dependencies.index(where: { $0.url == dependency.url }) else {
            throw IceError(message: "can't update dependency \(dependency.name)")
        }
        data.dependencies[index].requirement = requirement
    }
    
    public mutating func removeDependency(named name: String) throws {
        guard let index = data.dependencies.index(where: { $0.name == name }) else {
            throw IceError(message: "no dependency named \(name)")
        }
        data.dependencies.remove(at: index)
        
        var libs = retrieveLibrariesOfDependency(named: name)
        if libs.isEmpty {
            libs.append(name)
        }
        for lib in libs {
            removeDependencyFromTargets(named: lib)
        }
    }
    
    // MARK: - Targets
    
    public mutating func addTarget(name: String, type: Package.Target.TargetType, dependencies: [String]) {
        let dependencies = dependencies.map { Package.Target.Dependency(name: $0) }
        data.targets.append(.init(
            name: name,
            type: type,
            dependencies: dependencies,
            path: nil,
            exclude: [],
            sources: nil,
            publicHeadersPath: nil,
            pkgConfig: nil,
            providers: nil
        ))
    }
    
    public mutating func depend(target: String, on lib: String) throws {
        guard let targetIndex = data.targets.index(where: { $0.name == target }) else {
            throw IceError(message: "target '\(target)' not found")
        }
        if data.targets[targetIndex].dependencies.contains(where: { $0.name == lib }) {
            return
        }
        data.targets[targetIndex].dependencies.append(.init(name: lib))
    }
    
    public mutating func removeTarget(named name: String) throws {
        guard let index = data.targets.index(where: { $0.name == name }) else {
            throw IceError(message: "can't remove target \(name)")
        }
        data.targets.remove(at: index)
        
        removeDependencyFromTargets(named: name)
        
        data.products = data.products.map { (oldProduct) in
            var newProduct = oldProduct
            newProduct.targets = newProduct.targets.filter { $0 != name }
            return newProduct
        }
    }
    
    // MARK: - Helpers
    
    private mutating func removeDependencyFromTargets(named name: String) {
        data.targets = data.targets.map { (oldTarget) in
            var newTarget = oldTarget
            newTarget.dependencies = newTarget.dependencies.filter { $0.name != name }
            return newTarget
        }
    }
    
    // MARK: -
    
    public func retrieveLibrariesOfDependency(named dependency: String) -> [String] {
        let glob = (config.localDirectory + ".build" + "checkouts").glob("\(dependency)*")
        guard let path = glob.first,
            let contents: String = try? (path + Package.fileName).read().replacingOccurrences(of: "\n", with: " ") else {
                return []
        }
        let matches = Package.libRegex.allMatches(in: contents)
        #if swift(>=4.1)
        return matches.compactMap { $0.captures[0] }
        #else
        return matches.flatMap { $0.captures[0] }
        #endif
    }
    
    public mutating func sync() throws {
        if !dirty {
            return
        }
        
        let path = config.localDirectory + Package.fileName
        try path.write(Data())
        guard let fileStream = WriteStream(path: path.string) else  {
            throw IceError(message: "couldn't write to \(path)")
        }
        
        try write(to: fileStream)
        dirty = false
    }
    
    public func write(to stream: WritableStream) throws {
        let writer = try PackageWriter(package: self)
        try writer.write(to: stream)
    }
    
}

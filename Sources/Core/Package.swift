//
//  Package.swift
//  Core
//
//  Created by Jake Heiser on 8/27/17.
//

import Foundation
import SwiftCLI
import FileKit

public struct Package: Decodable {
    
    public struct Product: Decodable {
        public let name: String
        public let product_type: String
        public var targets: [String]
        public let type: String? // If library, static or dynamic
        
        public var isExecutable: Bool {
            return product_type == "executable"
        }
    }
    
    public struct Dependency: Decodable {
        public struct Requirement: Decodable {
            let type: String
            let lowerBound: String?
            let upperBound: String?
            let identifier: String?
        }
        
        public let url: String
        public let requirement: Requirement
    }
    
    public struct Target: Decodable {
        public struct Dependency: Decodable {
            let name: String
        }
        
        public let name: String
        public let isTest: Bool
        public var dependencies: [Dependency]
        public let path: String?
        public let exclude: [String]
        public let sources: [String]?
        public let publicHeadersPath: String?
        
        func strictVersion() -> Target {
            return Target(
                name: name,
                isTest: isTest,
                dependencies: dependencies.sorted { $0.name < $1.name },
                path: path,
                exclude: exclude,
                sources: sources,
                publicHeadersPath: publicHeadersPath
            )
        }
    }
    
    public let name: String
    public private(set) var products: [Product]
    public private(set) var dependencies: [Dependency]
    public private(set) var targets: [Target]
    
    public static func load(directory: Path) throws -> Package {
        let data = try SPM(path: directory).dumpPackage()
        return try load(data: data)
    }
    
    public static func load(data: Data) throws -> Package {
        do {
            return try JSONDecoder().decode(Package.self, from: data)
        } catch {
            throw IceError(message: "couldn't parse Package.swift")
        }
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
        let newProduct = Product(name: name, product_type: productType, targets: targets, type: libraryType)
        products.append(newProduct)
    }
    
    public mutating func removeProduct(name: String) throws {
        guard let index = products.index(where: { $0.name == name }) else {
            throw IceError(message: "can't remove product \(name)")
        }
        products.remove(at: index)
    }
    
    // MARK: - Dependencies
    
    public mutating func addDependency(ref: RepositoryReference, version: Version) {
        let requirement = Dependency.Requirement(
            type: "range",
            lowerBound: version.raw,
            upperBound: Version(version.major + 1, 0, 0).raw,
            identifier: nil
        )
        dependencies.append(Dependency(url: ref.url, requirement: requirement))
    }
    
    public mutating func removeDependency(named name: String) throws {
        guard let index = dependencies.index(where: { RepositoryReference(url: $0.url).name == name }) else {
            throw IceError(message: "can't remove dependency \(name)")
        }
        dependencies.remove(at: index)
        
        removeDependencyFromTargets(named: name)
    }
    
    // MARK: - Targets
    
    public mutating func addTarget(name: String, isTest: Bool, dependencies: [String]) {
        let dependencies = dependencies.map { Package.Target.Dependency(name: $0) }
        let newTarget = Target(
            name: name,
            isTest: isTest,
            dependencies: dependencies,
            path: nil,
            exclude: [],
            sources: nil,
            publicHeadersPath: nil
        )
        targets.append(newTarget)
    }
    
    public mutating func depend(target: String, on lib: String) throws {
        guard let targetIndex = targets.index(where:  { $0.name == target }) else {
            throw IceError(message: "target \(target) not found")
        }
        if targets[targetIndex].dependencies.contains(where: { $0.name == lib }) {
            return
        }
        targets[targetIndex].dependencies.append(Target.Dependency(name: lib))
    }
    
    public mutating func removeTarget(named name: String) throws {
        guard let index = targets.index(where: { $0.name == name }) else {
            throw IceError(message: "can't remove target \(name)")
        }
        targets.remove(at: index)
        
        removeDependencyFromTargets(named : name)
        
        products = products.map { (oldProduct) in
            var newProduct = oldProduct
            newProduct.targets = newProduct.targets.filter { $0 != name }
            return newProduct
        }
    }
    
    // MARK: - Helpers
    
    private mutating func removeDependencyFromTargets(named name: String) {
        targets = targets.map { (oldTarget) in
            var newTarget = oldTarget
            newTarget.dependencies = newTarget.dependencies.filter { $0.name != name }
            return newTarget
        }
    }
    
    // MARK: -
    
    public func strictVersion() -> Package {
        return Package(
            name: name,
            products: products.sorted {
                if $0.isExecutable && !$1.isExecutable { return true }
                if !$0.isExecutable && $1.isExecutable { return false }
                return $0.name < $1.name
            },
            dependencies: dependencies.sorted {
                RepositoryReference(url: $0.url).name < RepositoryReference(url: $1.url).name
            },
            targets: targets.sorted {
                if $0.isTest && !$1.isTest { return false }
                if !$0.isTest && $1.isTest { return true }
                return $0.name < $1.name
            }.map { $0.strictVersion() }
        )
    }
    
    public func write(to stream: OutputByteStream? = nil) throws {
        let writePackage = Ice.config.get(\.strict) ? strictVersion() : self
        let writer = try PackageWriter(stream: stream)
        writer.write(package: writePackage)
    }
    
}

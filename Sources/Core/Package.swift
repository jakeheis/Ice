//
//  Package.swift
//  Core
//
//  Created by Jake Heiser on 8/27/17.
//

import Foundation

public struct Package: Decodable {
    
    struct Dependency: Decodable {
        struct Requirement: Decodable {
            let lowerBound: String
            let upperBound: String?
        }
        
        let url: String
        let requirement: Requirement
        
        init(url: String, version: Version) {
            self.url = url
            self.requirement = Requirement(lowerBound: String(describing: version), upperBound: nil)
        }
    }
    
    struct Product: Decodable {
        let name: String
        let product_type: String
        let targets: [String]
    }
    
    struct Target: Decodable {
        struct Dependency: Decodable {
            let name: String
        }
        
        let name: String
        let isTest: Bool
        var dependencies: [Dependency]
    }
    
    let name: String
    private(set) var dependencies: [Dependency]
    private(set) var products: [Product]
    private(set) var targets: [Target]
    
    public static func load(directory: String) throws -> Package {
        let rawPackage = try SPM(path: directory).dumpPackage()
        return try JSONDecoder().decode(Package.self, from: rawPackage)
    }
    
    public mutating func addDependency(ref: RepositoryReference, version: Version) {
        dependencies.append(Dependency(url: ref.url, version: version))
    }
    
    public mutating func addTarget(name: String, isTest: Bool, dependencies: [String]) {
        let dependencies = dependencies.map { Package.Target.Dependency(name: $0) }
        let newTarget = Target(name: name, isTest: isTest, dependencies: dependencies)
        targets.append(newTarget)
    }
    
    public mutating func depend(target: String, on lib: String) throws {
        guard let targetIndex = targets.index(where:  { $0.name == target }) else {
            throw SwiftProcess.Error.processFailed
        }
        targets[targetIndex].dependencies.append(Target.Dependency(name: lib))
    }
    
    public func write(print: Bool = false) throws {
        let buffer = FileBuffer(path: "Package.swift")
        
        buffer += [
            "// swift-tools-version:4.0",
            "// Managed by ice",
            "",
            "import PackageDescription",
            "",
            "let package = Package(",
        ]
        
        buffer.indent()
        
        buffer += "name: \(name.quoted),"
        
        if !products.isEmpty {
            buffer += "products: ["
            buffer.indent()
            for product in products {
                let targetsPortion = product.targets.map { $0.quoted }.joined(separator: ", ")
                buffer += ".\(product.product_type)(name: \(product.name.quoted), targets: [\(targetsPortion)]),"
            }
            buffer.unindent()
            buffer += "],"
        }
        
        if !dependencies.isEmpty {
            buffer += "dependencies: ["
            buffer.indent()
            for dependency in dependencies {
                let versionPortion = ".upToNextMinor(from: \"\(dependency.requirement.lowerBound)\")"
                buffer += ".package(url: \(dependency.url.quoted), \(versionPortion)),"
            }
            buffer.unindent()
            buffer += "],"
        }
        
        if !targets.isEmpty {
            buffer += "targets: ["
            buffer.indent()
            for target in targets {
                let type = target.isTest ? ".testTarget" : ".target"
                let dependenciesPortion = target.dependencies.map { $0.name.quoted }.joined(separator: ", ")
                buffer += "\(type)(name: \(target.name.quoted), dependencies: [\(dependenciesPortion)]),"
            }
            buffer.unindent()
            buffer += "],"
        }
        
        var last = buffer.lines.removeLast()
        last = String(last[..<last.index(before: last.endIndex)])
        buffer.lines.append(last)
        
        buffer.unindent()
        buffer += ")"
        
        if print {
            buffer.print()
        } else {
            try buffer.write()
        }
    }
    
}

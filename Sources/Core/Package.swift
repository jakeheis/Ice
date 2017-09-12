//
//  Package.swift
//  Core
//
//  Created by Jake Heiser on 8/27/17.
//

import Foundation
import SwiftCLI
import Files

public struct Package: Decodable {
    
    public struct Dependency: Decodable {
        
        public struct Requirement: Decodable {
            let type: String
            let lowerBound: String?
            let upperBound: String?
            let identifier: String?
        }
        
        public let url: String
        public let requirement: Requirement
        
        init(url: String, version: Version) {
            self.url = url
            self.requirement = Requirement(type: "range", lowerBound: String(describing: version), upperBound: nil, identifier: nil)
        }
    }
    
    public struct Product: Decodable {
        public let name: String
        public let product_type: String
        public let targets: [String]
    }
    
    public struct Target: Decodable {
        public struct Dependency: Decodable {
            let name: String
        }
        
        public let name: String
        public let isTest: Bool
        public var dependencies: [Dependency]
        
        func strictVersion() -> Target {
            return Target(
                name: name,
                isTest: isTest,
                dependencies: dependencies.sorted { $0.name < $1.name}
            )
        }
    }
    
    public let name: String
    public private(set) var dependencies: [Dependency]
    public private(set) var products: [Product]
    public private(set) var targets: [Target]
    
    public static func load(directory: String) throws -> Package {
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
    
    public mutating func addDependency(ref: RepositoryReference, version: Version) {
        dependencies.append(Dependency(url: ref.url, version: version))
    }
    
    public mutating func removeDependency(named name: String) throws {
        guard let index = dependencies.index(where: { RepositoryReference(url: $0.url).name == name }) else {
            throw IceError(message: "can't remove dependency \(name)")
        }
        dependencies.remove(at: index)
        
        targets = targets.map { (oldTarget) in
            var newTarget = oldTarget
            newTarget.dependencies = newTarget.dependencies.filter { $0.name != name }
            return newTarget
        }
    }
    
    public mutating func addTarget(name: String, isTest: Bool, dependencies: [String]) {
        let dependencies = dependencies.map { Package.Target.Dependency(name: $0) }
        let newTarget = Target(name: name, isTest: isTest, dependencies: dependencies)
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
    
    public func strictVersion() -> Package {
        return Package(
            name: name,
            dependencies: dependencies.sorted {
                RepositoryReference(url: $0.url).name < RepositoryReference(url: $1.url).name
            },
            products: products.sorted { $0.name < $1.name },
            targets: targets.sorted {
                if $0.isTest && !$1.isTest { return false }
                if !$0.isTest && $1.isTest { return true }
                return $0.name < $1.name
            }.map { $0.strictVersion() }
        )
    }
    
    public func write(to stream: OutputByteStream? = nil) throws {
        try write(to: stream, isStrict: false)
    }
    
    private func write(to stream: OutputByteStream?, isStrict: Bool) throws {
        if Config.get(\.strict) && !isStrict {
            try strictVersion().write(to: stream, isStrict: true)
            return
        }
        
        let out: OutputByteStream
        if let stream = stream {
            out = stream
        } else {
            let file = "Package.swift"
            try File(path: file).write(string: "")
            guard let fileStream = FileStream(path: file) else  {
                throw IceError(message: "Couldn't write to \(file)")
            }
            out = fileStream
        }
        
        out << """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
        """
        
        out << "    name: \(name.quoted),"
        
        if !products.isEmpty {
            out << "    products: ["
            for product in products {
                let targetsPortion = product.targets.map { $0.quoted }.joined(separator: ", ")
                out << "        .\(product.product_type)(name: \(product.name.quoted), targets: [\(targetsPortion)]),"
            }
            out << "    ],"
        }
        
        if !dependencies.isEmpty {
            out << "    dependencies: ["
            for dependency in dependencies {
                let versionPortion: String
                switch dependency.requirement.type {
                case "range":
                    versionPortion = "from: \(dependency.requirement.lowerBound!.quoted)"
                case "branch":
                    versionPortion = ".branchItem(\(dependency.requirement.identifier!.quoted))"
                default:
                    fatalError("Unsupported dependency requirement type: \(dependency.requirement.type)")
                }
                out << "        .package(url: \(dependency.url.quoted), \(versionPortion)),"
            }
            out << "    ],"
        }
        
        if !targets.isEmpty {
            out << "    targets: ["
            for target in targets {
                let type = target.isTest ? ".testTarget" : ".target"
                let dependenciesPortion = target.dependencies.map { $0.name.quoted }.joined(separator: ", ")
                out << "        \(type)(name: \(target.name.quoted), dependencies: [\(dependenciesPortion)]),"
            }
            out << "    ]"
        } else {
            out << "    targets: []"
        }
        
        out << ")"
    }
    
}

//
//  PackageWriter.swift
//  Core
//
//  Created by Jake Heiser on 9/24/17.
//

import FileKit
import SwiftCLI

class PackageWriter {
    
    let out: OutputByteStream
    
    init(stream: OutputByteStream?) throws {        
        if let stream = stream {
            self.out = stream
        } else {
            let file = "Package.swift"
            try "".write(to: Path(file)) // Overwrite file
            guard let fileStream = FileStream(path: file) else  {
                throw IceError(message: "Couldn't write to \(file)")
            }
            self.out = fileStream
        }
    }
    
    func write(package: Package) {
        writeStart()
        writeName(package.name)
        writeProducts(package.products)
        writeDependencies(package.dependencies)
        writeTargets(package.targets)
        writeEnd()
    }
    
    func writeStart() {
        out <<< """
        // swift-tools-version:4.0
        // Managed by ice
        
        import PackageDescription
        
        let package = Package(
        """
    }
    
    func writeName(_ name: String) {
        out <<< "    name: \(name.quoted),"
    }
    
    func writeProducts(_ products: [Package.Product]) {
        if products.isEmpty {
            return
        }
        
        out <<< "    products: ["
        for product in products {
            let targetsPortion = product.targets.map { $0.quoted }.joined(separator: ", ")
            let typePortion: String
            if let type = product.type {
                typePortion = ", type: .\(type)"
            } else {
                typePortion = ""
            }
            out <<< "        .\(product.product_type)(name: \(product.name.quoted)\(typePortion), targets: [\(targetsPortion)]),"
        }
        out <<< "    ],"
    }
    
    func writeDependencies(_ dependencies: [Package.Dependency]) {
        if dependencies.isEmpty {
            return
        }
        
        out <<< "    dependencies: ["
        for dependency in dependencies {
            let versionPortion: String
            
            if dependency.requirement.type == "range" {
                guard let lowerBoundString = dependency.requirement.lowerBound, let lowerBound = Version(lowerBoundString),
                    let upperBoundString = dependency.requirement.upperBound, let upperBound = Version(upperBoundString) else {
                        fatalError("Wrong")
                }
                if upperBound == Version(lowerBound.major + 1, 0, 0) {
                    versionPortion = "from: \(lowerBoundString.quoted)"
                } else if upperBound == Version(lowerBound.major, lowerBound.minor + 1, 0) {
                    versionPortion = ".upToNextMinor(from: \(lowerBoundString.quoted))"
                } else {
                    versionPortion = "\(lowerBoundString.quoted)..<\(upperBoundString.quoted)"
                }
            } else {
                guard let identifier = dependency.requirement.identifier else {
                    fatalError("Wrong")
                }
                let function: String
                switch dependency.requirement.type {
                case "branch": function = "branchItem"
                case "exact": function = "exact"
                case "revision": function = "revision"
                default: fatalError("Unsupported dependency requirement type: \(dependency.requirement.type)")
                }
                versionPortion = ".\(function)(\(identifier.quoted))"
            }
            
            out <<< "        .package(url: \(dependency.url.quoted), \(versionPortion)),"
        }
        out <<< "    ],"
    }
    
    func writeTargets(_ targets: [Package.Target]) {
        if targets.isEmpty {
            out <<< "    targets: []"
        } else {
            out <<< "    targets: ["
            for target in targets {
                var line = "        "
                line += target.isTest ? ".testTarget" : ".target"
                line += "(name: \(target.name.quoted)"
                line += ", dependencies: [" + target.dependencies.map { $0.name.quoted }.joined(separator: ", ") + "]"
                if let path = target.path {
                    line += ", path: \(path.quoted)"
                }
                if !target.exclude.isEmpty {
                    line += ", exclude: [" + target.exclude.map { $0.quoted }.joined(separator: ", ") + "]"
                }
                if let sources = target.sources {
                    line += ", sources: [" + sources.map { $0.quoted }.joined(separator: ", ") + "]"
                }
                if let publicHeadersPath = target.publicHeadersPath {
                    line += ", publicHeadersPath: \(publicHeadersPath.quoted)"
                }
                line += "),"
                out <<< line
            }
            out <<< "    ]"
        }
    }
    
    func writeEnd() {
        out <<< ")"
    }
    
}

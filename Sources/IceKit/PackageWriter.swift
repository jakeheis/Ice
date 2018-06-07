//
//  PackageWriter.swift
//  Core
//
//  Created by Jake Heiser on 9/24/17.
//

import FileKit
import SwiftCLI

class PackageWriter {
    
    private let out: IndentStream
    
    init(stream: WritableStream) {
        self.out = IndentStream(out: stream)
    }
    
    func write(package: Package) {
        writeStart()
        out.indent {
            writeName(package.name)
            writePkgConfig(package.pkgConfig)
            writeProviders(package.providers)
            writeProducts(package.products)
            writeDependencies(package.dependencies)
            writeTargets(package.targets)
            writeSwiftLanguageVersion(package.swiftLanguageVersions)
            writeCLangaugeStandard(package.cLanguageStandard)
            writeCxxLangaugeStandard(package.cxxLanguageStandard)
        }
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
        out <<< "name: \(name.quoted),"
    }
    
    func writePkgConfig(_ pkgConfig: String?) {
        if let pkgConfig = pkgConfig {
            out <<< "pkgConfig: \(pkgConfig.quoted),"
        }
    }
    
    func writeProviders(_ providers: [Package.Provider]?) {
        guard let providers = providers, !providers.isEmpty else {
            return
        }
        out <<< "providers: ["
        out.indentEach(providers) { (provider) in
            let values = provider.values.map { $0.quoted }.joined(separator: ", ")
            out <<< ".\(provider.name)([\(values)]),"
        }
        out <<< "],"
    }
    
    func writeProducts(_ products: [Package.Product]) {
        if products.isEmpty {
            return
        }
        
        out <<< "products: ["
        out.indentEach(products) { (product) in
            let targetsPortion = product.targets.map { $0.quoted }.joined(separator: ", ")
            let typePortion: String
            if let type = product.type {
                typePortion = ", type: .\(type)"
            } else {
                typePortion = ""
            }
            out <<< ".\(product.product_type)(name: \(product.name.quoted)\(typePortion), targets: [\(targetsPortion)]),"
        }
        out <<< "],"
    }
    
    func writeDependencies(_ dependencies: [Package.Dependency]) {
        if dependencies.isEmpty {
            return
        }
        
        out <<< "dependencies: ["
        out.indentEach(dependencies) { (dependency) in
            let versionPortion: String
            
            if dependency.requirement.type == .range {
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
                case .branch: function = "branchItem"
                case .exact: function = "exact"
                case .revision: function = "revision"
                default: return
                }
                versionPortion = ".\(function)(\(identifier.quoted))"
            }
            
            out <<< ".package(url: \(dependency.url.quoted), \(versionPortion)),"
        }
        out <<< "],"
    }
    
    func writeTargets(_ targets: [Package.Target]) {
        if targets.isEmpty {
            out <<< "targets: []"
        } else {
            out <<< "targets: ["
            out.indentEach(targets) { (target) in
                var line = target.isTest ? ".testTarget" : ".target"
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
            out <<< "]"
        }
    }
    
    func writeSwiftLanguageVersion(_ versions: [Int]?) {
        if let versions = versions {
            let stringVersions = versions.map(String.init).joined(separator: ", ")
            out <<< "swiftLanguageVersions: [\(stringVersions)],"
        }
    }
    
    func writeCLangaugeStandard(_ standard: String?) {
        if let standard = standard {
            let converted = standard.replacingOccurrences(of: ":", with: "_")
            out <<< "cLanguageStandard: .\(converted),"
        }
    }
    
    func writeCxxLangaugeStandard(_ standard: String?) {
        if let standard = standard {
            let converted = standard
                .replacingOccurrences(of: "c++", with: "cxx")
                .replacingOccurrences(of: "gnu++", with: "gnucxx")
            out <<< "cxxLanguageStandard: .\(converted),"
        }
    }
    
    func writeEnd() {
        out <<< ")"
    }
    
}

// MARK: -

private class IndentStream {
    
    let out: WritableStream
    
    private var indentationLevel = 0
    
    init(out: WritableStream) {
        self.out = out
    }
    
    func print(_ content: String) {
        out <<< String(repeating: "    ", count: indentationLevel) + content
    }
    
    func indent(_ go: () -> ()) {
        indentationLevel += 1
        go()
        indentationLevel -= 1
    }
    
    func indentEach<T>(_ objects: [T], _ each: (T) -> ()) {
        indent {
            for obj in objects {
                each(obj)
            }
        }
    }
    
}

private func <<<(stream: IndentStream, text: String) {
    stream.print(text)
}

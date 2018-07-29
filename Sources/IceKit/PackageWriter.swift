//
//  PackageWriter.swift
//  Core
//
//  Created by Jake Heiser on 9/24/17.
//

import SwiftCLI

public class PackageWriter {
    
    private let writer: PackageWriterImpl
    
    public init(package: PackageV4_2, toolsVersion: SwiftToolsVersion) throws {
        if toolsVersion >= SwiftToolsVersion.v4_2 {
            self.writer = Version4_2Writer(package: package, toolsVersion: toolsVersion)
        } else if toolsVersion >= SwiftToolsVersion.v4 {
            self.writer = Version4_0Writer(package: package, toolsVersion: toolsVersion)
        } else {
            throw IceError(message: "tools version \(toolsVersion) not supported")
        }
    }
    
    public func write(to stream: WritableStream) throws {
        try writer.write(to: stream)
    }
    
}

protocol PackageWriterImpl {
    var package: PackageV4_2 { get }
    var toolsVersion: SwiftToolsVersion { get }
    
    init(package: PackageV4_2, toolsVersion: SwiftToolsVersion)
    
    func addSwiftLanguageVersions(_ versions: [String]?, to arguments: PackageArguments) throws
}

extension PackageWriterImpl {
    
    func write(to out: WritableStream) throws {
        // Iniitally write to intermediate stream so that if an error is thrown, partial package is not written
        let stream = CaptureStream()
        
        stream <<< """
        // swift-tools-version:\(toolsVersion)
        // Managed by ice
        
        import PackageDescription
        
        let package = Package(
        """
        
        let arguments = PackageArguments()
        addName(package.name, to: arguments)
        addPkgConfig(package.pkgConfig, to: arguments)
        addProviders(package.providers, to: arguments)
        addProducts(package.products, to: arguments)
        addDependencies(package.dependencies, to: arguments)
        addTargets(package.targets, to: arguments)
        try addSwiftLanguageVersions(package.swiftLanguageVersions, to: arguments)
        addCLangaugeStandard(package.cLanguageStandard, to: arguments)
        addCxxLangaugeStandard(package.cxxLanguageStandard, to: arguments)
        arguments.write(to: stream)
        
        stream <<< ")"
        
        stream.closeWrite()
        out.write(stream.readAll())
    }
    
    func addName(_ name: String, to arguments: PackageArguments) {
        arguments.addSimple(key: "name", value: name.quoted)
    }
    
    func addPkgConfig(_ pkgConfig: String?, to arguments: PackageArguments) {
        if let pkgConfig = pkgConfig {
            arguments.addSimple(key: "pkgConfig", value: pkgConfig.quoted)
        }
    }
    
    func addProviders(_ providers: [PackageV4_2.Provider]?, to arguments: PackageArguments) {
        guard let providers = providers, !providers.isEmpty else {
            return
        }
        arguments.addArray(key: "providers", children: providers.map { (provider) in
            let values = provider.values.map { $0.quoted }.joined(separator: ", ")
            return ".\(provider.name)([\(values)])"
        })
    }
    
    func addProducts(_ products: [PackageV4_2.Product], to arguments: PackageArguments) {
        if products.isEmpty {
            return
        }
        
        arguments.addArray(key: "products", children: products.map { (product) in
            let targetsPortion = product.targets.map { $0.quoted }.joined(separator: ", ")
            let typePortion: String
            if let type = product.type {
                typePortion = ", type: .\(type)"
            } else {
                typePortion = ""
            }
            return ".\(product.product_type)(name: \(product.name.quoted)\(typePortion), targets: [\(targetsPortion)])"
        })
    }
    
    func addDependencies(_ dependencies: [PackageV4_2.Dependency], to arguments: PackageArguments) {
        if dependencies.isEmpty {
            return
        }
        
        arguments.addArray(key: "dependencies", children: dependencies.map { (dependency) in
            let versionPortion: String
            
            if dependency.requirement.type == .range {
                guard let lowerBoundString = dependency.requirement.lowerBound, let lowerBound = Version(lowerBoundString),
                    let upperBoundString = dependency.requirement.upperBound, let upperBound = Version(upperBoundString) else {
                        niceFatalError("Impossible dependency requirement; invalid range specified")
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
                    niceFatalError("Impossible dependency requirement; \(dependency.requirement.type) specified, but no identifier given")
                }
                let function: String
                switch dependency.requirement.type {
                case .branch: function = "branchItem"
                case .exact: function = "exact"
                case .revision: function = "revision"
                default: fatalError()
                }
                versionPortion = ".\(function)(\(identifier.quoted))"
            }
            
            return ".package(url: \(dependency.url.quoted), \(versionPortion))"
        })
    }
    
    func addTargets(_ targets: [PackageV4_2.Target], to arguments: PackageArguments) {
        if targets.isEmpty {
            arguments.addSimple(key: "targets", value: "[]")
        } else {
            arguments.addArray(key: "targets", children: targets.map { (target) in
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
                line += ")"
                return line
            })
        }
    }
    
    func addCLangaugeStandard(_ standard: String?, to arguments: PackageArguments) {
        if let standard = standard {
            let converted = standard.replacingOccurrences(of: ":", with: "_")
            arguments.addSimple(key: "cLanguageStandard", value: ".\(converted)")
        }
    }
    
    func addCxxLangaugeStandard(_ standard: String?, to arguments: PackageArguments) {
        if let standard = standard {
            let converted = standard
                .replacingOccurrences(of: "c++", with: "cxx")
                .replacingOccurrences(of: "gnu++", with: "gnucxx")
            arguments.addSimple(key: "cxxLanguageStandard", value: ".\(converted)")
        }
    }
    
    fileprivate func createVersionError() -> Error {
        return IceError(message: "cannot write package in version \(toolsVersion); try a different tools version")
    }
    
}

final class Version4_0Writer: PackageWriterImpl {
    
    let package: PackageV4_2
    let toolsVersion: SwiftToolsVersion
    
    init(package: PackageV4_2, toolsVersion: SwiftToolsVersion) {
        self.package = package
        self.toolsVersion = toolsVersion
    }
    
    func addSwiftLanguageVersions(_ versions: [String]?, to arguments: PackageArguments) throws {
        if let versions = versions {
            guard !versions.map(Int.init).contains(nil) else {
                throw createVersionError()
            }
            let stringVersions = versions.joined(separator: ", ")
            arguments.addSimple(key: "swiftLanguageVersions", value: "[\(stringVersions)]")
        }
    }
    
}

final class Version4_2Writer: PackageWriterImpl {
    
    let package: PackageV4_2
    let toolsVersion: SwiftToolsVersion
    
    init(package: PackageV4_2, toolsVersion: SwiftToolsVersion) {
        self.package = package
        self.toolsVersion = toolsVersion
    }
    
    func addSwiftLanguageVersions(_ versions: [String]?, to arguments: PackageArguments) {
        if let versions = versions {
            var enumVersions: [String] = []
            for version in versions {
                if version == "3" {
                    enumVersions.append(".v3")
                } else if version == "4" {
                    enumVersions.append(".v4")
                } else if version == "4.2" {
                    enumVersions.append(".v4_2")
                } else {
                    enumVersions.append(".version(\(version))")
                }
            }
            arguments.addSimple(key: "swiftLanguageVersions", value: "[\(enumVersions.joined(separator: ", "))]")
        }
    }
    
}

// MARK: - PackageArgument

protocol PackageArgument {
    func write(to stream: WritableStream, terminator: String)
}

extension PackageArgument {
    var singleIndent: String {
        return "    "
    }
    
    var doubleIndent: String {
        return String(repeating: singleIndent, count: 2)
    }
}

class PackageArguments {
    
    struct SimpleArgument: PackageArgument {
        let key: String
        let value: Any
        
        func write(to stream: WritableStream, terminator: String) {
            stream <<< singleIndent + key + ": " + String(describing: value) + terminator
        }
    }
    
    struct ArrayArgument: PackageArgument {
        let key: String
        let children: [String]
        
        func write(to stream: WritableStream, terminator: String) {
            stream <<< singleIndent + key + ": ["
            for child in children {
                stream <<< doubleIndent + child + ","
            }
            stream <<< singleIndent + "]" + terminator
        }
    }
    
    private var arguments: [PackageArgument] = []
    
    func addSimple(key: String, value: Any) {
        arguments.append(SimpleArgument(key: key, value: value))
    }
    
    func addArray(key: String, children: [String]) {
        arguments.append(ArrayArgument(key: key, children: children))
    }
    
    func write(to stream: WritableStream) {
        for (index, argument) in arguments.enumerated() {
            let terminator = (index == arguments.index(before: arguments.endIndex) ? "" : ",")
            argument.write(to: stream, terminator: terminator)
        }
    }
    
}

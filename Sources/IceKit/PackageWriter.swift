//
//  PackageWriter.swift
//  Core
//
//  Created by Jake Heiser on 9/24/17.
//

import SwiftCLI

public class PackageWriter {
    
    private let writer: PackageWriterImpl
    
    public convenience init(package: Package, format: Bool = false) throws {
        let data = format ? PackageFormatter(package: package.data).format() : package.data
        try self.init(package: data, toolsVersion: package.toolsVersion)
    }
    
    public init(package: ModernPackageData, toolsVersion: SwiftToolsVersion) throws {
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
    static var baseVersion: SwiftToolsVersion { get }
    
    var package: ModernPackageData { get }
    var toolsVersion: SwiftToolsVersion { get }
    
    init(package: ModernPackageData, toolsVersion: SwiftToolsVersion)
    
    func addSwiftLanguageVersions(_ versions: [String]?, to function: inout FunctionCallComponent) throws
}

extension PackageWriterImpl {
    
    func write(to out: WritableStream) throws {
        var function = FunctionCallComponent(name: "Package")
        addName(package.name, to: &function)
        addPkgConfig(package.pkgConfig, to: &function)
        addProviders(package.providers, to: &function)
        addProducts(package.products, to: &function)
        try addDependencies(package.dependencies, to: &function)
        try addTargets(package.targets, to: &function)
        try addSwiftLanguageVersions(package.swiftLanguageVersions, to: &function)
        addCLangaugeStandard(package.cLanguageStandard, to: &function)
        addCxxLangaugeStandard(package.cxxLanguageStandard, to: &function)
        
        out <<< """
        // swift-tools-version:\(toolsVersion)
        // Managed by ice
        
        import PackageDescription
        
        let package = \(function.render())
        """
    }
    
    func addName(_ name: String, to function: inout FunctionCallComponent) {
        function.addQuoted(key: "name", value: name)
    }
    
    func addPkgConfig(_ pkgConfig: String?, to function: inout FunctionCallComponent) {
        if let pkgConfig = pkgConfig {
            function.addQuoted(key: "pkgConfig", value: pkgConfig)
        }
    }
    
    func addProviders(_ providers: [Package.Provider]?, to function: inout FunctionCallComponent) {
        guard let providers = providers, !providers.isEmpty else {
            return
        }
        function.addMultilineArray(key: "providers", children: providers.map { (provider) in
            return providerComponent(for: provider)
        })
    }
    
    func addProducts(_ products: [Package.Product], to function: inout FunctionCallComponent) {
        if products.isEmpty {
            return
        }
        
        function.addMultilineArray(key: "products", children: products.map { (product) in
            var prodFunc = FunctionCallComponent(staticMember: product.product_type)
            prodFunc.addQuoted(key: "name", value: product.name)
            if let type = product.type {
                prodFunc.addSimple(key: "type", value: "." + type)
            }
            prodFunc.addSingleLineArray(key: "targets", children: product.targets.quoted())
            return prodFunc
        })
    }
    
    func addDependencies(_ dependencies: [Package.Dependency], to function: inout FunctionCallComponent) throws {
        if dependencies.isEmpty {
            return
        }
        
        function.addMultilineArray(key: "dependencies", children: try dependencies.map { (dependency) in
            var depFunction = FunctionCallComponent(staticMember: "package")
            if dependency.requirement.type == .localPackage {
                if Self.baseVersion < .v4_2 {
                    throw createVersionError()
                }
                depFunction.addQuoted(key: "path", value: dependency.url)
            } else {
                depFunction.addQuoted(key: "url", value: dependency.url)
            }
            
            switch dependency.requirement.type {
            case .range:
                guard let lowerBoundString = dependency.requirement.lowerBound, let lowerBound = Version(lowerBoundString),
                    let upperBoundString = dependency.requirement.upperBound, let upperBound = Version(upperBoundString) else {
                        throw IceError(message: "impossible dependency requirement; invalid range specified")
                }
                if upperBound == Version(lowerBound.major + 1, 0, 0) {
                    depFunction.addQuoted(key: "from", value: lowerBoundString)
                } else if upperBound == Version(lowerBound.major, lowerBound.minor + 1, 0) {
                    var upToMinor = FunctionCallComponent(staticMember: "upToNextMinor")
                    upToMinor.addQuoted(key: "from", value: lowerBoundString)
                    depFunction.addArgument(key: nil, component: upToMinor)
                } else {
                    depFunction.addSimple(key: nil, value: "\(lowerBoundString.quoted)..<\(upperBoundString.quoted)")
                }
            case .branch, .exact, .revision:
                guard let identifier = dependency.requirement.identifier else {
                    throw IceError(message: "impossible dependency requirement; \(dependency.requirement.type) specified, but no identifier given")
                }
                var idFunc = FunctionCallComponent(staticMember: dependency.requirement.type.rawValue)
                idFunc.addQuoted(key: nil, value: identifier)
                depFunction.addArgument(key: nil, component: idFunc)
            case .localPackage: break
            }
            
            return depFunction
        })
    }
    
    func addTargets(_ targets: [Package.Target], to function: inout FunctionCallComponent) throws {
        if targets.isEmpty {
            function.addSingleLineArray(key: "targets", children: [])
        } else {
            function.addMultilineArray(key: "targets", children: try targets.map { (target) in
                let functionName: String
                switch target.type {
                case .regular: functionName = "target"
                case .test: functionName = "testTarget"
                case .system: functionName = "systemLibrary"
                }
                
                var functionCall = FunctionCallComponent(staticMember: functionName)
                functionCall.addQuoted(key: "name", value: target.name)
                if target.type == .regular || target.type == .test {
                    functionCall.addSingleLineArray(key: "dependencies", children: target.dependencies.map({ $0.name.quoted }))
                }
                if let path = target.path {
                    functionCall.addQuoted(key: "path", value: path)
                }
                if target.type == .system {
                    if Self.baseVersion < .v4_2 {
                        throw createVersionError()
                    }
                    if let pkgConfig = target.pkgConfig {
                        functionCall.addQuoted(key: "pkgConfig", value: pkgConfig)
                    }
                    if let providers = target.providers {
                        functionCall.addMultilineArray(key: "providers", children: providers.map(providerComponent))
                    }
                } else {
                    if !target.exclude.isEmpty {
                        functionCall.addSingleLineArray(key: "exclude", children: target.exclude.quoted())
                    }
                    if let sources = target.sources {
                        functionCall.addSingleLineArray(key: "sources", children: sources.quoted())
                    }
                    if target.type == .regular, let publicHeadersPath = target.publicHeadersPath {
                        functionCall.addQuoted(key: "publicHeadersPath", value: publicHeadersPath)
                    }
                }
                return functionCall
            })
        }
    }
    
    func addCLangaugeStandard(_ standard: String?, to function: inout FunctionCallComponent) {
        if let standard = standard {
            let converted = standard.replacingOccurrences(of: ":", with: "_")
            function.addSimple(key: "cLanguageStandard", value: ".\(converted)")
        }
    }
    
    func addCxxLangaugeStandard(_ standard: String?, to function: inout FunctionCallComponent) {
        if let standard = standard {
            let converted = standard
                .replacingOccurrences(of: "c++", with: "cxx")
                .replacingOccurrences(of: "gnu++", with: "gnucxx")
            function.addSimple(key: "cxxLanguageStandard", value: ".\(converted)")
        }
    }
    
    fileprivate func createVersionError() -> Error {
        return IceError(message: "cannot write package in version \(toolsVersion); try a different tools version")
    }
    
    private func providerComponent(for provider: Package.Provider) -> Component {
        var provFunc = FunctionCallComponent(staticMember: provider.name)
        provFunc.addSingleLineArray(key: nil, children: provider.values.quoted())
        return provFunc
    }
    
}

final class Version4_0Writer: PackageWriterImpl {
    
    static let baseVersion = SwiftToolsVersion.v4
    
    let package: ModernPackageData
    let toolsVersion: SwiftToolsVersion
    
    init(package: ModernPackageData, toolsVersion: SwiftToolsVersion) {
        self.package = package
        self.toolsVersion = toolsVersion
    }
    
    func addSwiftLanguageVersions(_ versions: [String]?, to function: inout FunctionCallComponent) throws {
        if let versions = versions {
            guard !versions.map(Int.init).contains(nil) else {
                throw createVersionError()
            }
            function.addSingleLineArray(key: "swiftLanguageVersions", children: versions)
        }
    }
    
}

final class Version4_2Writer: PackageWriterImpl {
    
    static let baseVersion = SwiftToolsVersion.v4_2
    
    let package: ModernPackageData
    let toolsVersion: SwiftToolsVersion
    
    init(package: ModernPackageData, toolsVersion: SwiftToolsVersion) {
        self.package = package
        self.toolsVersion = toolsVersion
    }
    
    func addSwiftLanguageVersions(_ versions: [String]?, to function: inout FunctionCallComponent) throws {
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
            function.addSingleLineArray(key: "swiftLanguageVersions", children: enumVersions)
        }
    }
    
}

// MARK: - Components

protocol Component {
    func render() -> String
}

struct ValueComponent: Component {
    let value: Any
    func render() -> String {
        return String(describing: value)
    }
}

struct ArrayComponent: Component {
    let elements: [Component]
    let multiline: Bool
    
    func render() -> String {
        if multiline {
            let values = elements.map({ $0.render().indentingEachLine() }).joined(separator: ",\n") + ","
            return "[\n\(values)\n]"
        } else {
            let values = elements.map({ $0.render() }).joined(separator: ", ")
            return "[\(values)]"
        }
    }
}

struct ArgumentComponent: Component {
    let key: String?
    let value: Component
    func render() -> String {
        if let key = key {
            return "\(key): " + value.render()
        }
        return value.render()
    }
}

struct FunctionCallComponent: Component {
    let name: String
    var arguments: [ArgumentComponent]
    let linebreak: Bool
    
    init(name: String) {
        self.name = name
        self.arguments = []
        self.linebreak = true
    }
    
    init(staticMember: String) {
        self.name = "." + staticMember
        self.arguments = []
        self.linebreak = false
    }
    
    mutating func addQuoted(key: String?, value: String) {
        arguments.append(.init(key: key, value: ValueComponent(value: value.quoted)))
    }
    
    mutating func addSimple(key: String?, value: Any) {
        arguments.append(.init(key: key, value: ValueComponent(value: value)))
    }
    
    mutating func addMultilineArray(key: String?, children: [Component]) {
        arguments.append(.init(key: key, value: ArrayComponent(elements: children, multiline: true)))
    }
    
    mutating func addMultilineArray(key: String?, children: [Any]) {
        arguments.append(.init(key: key, value: ArrayComponent(elements: children.map({ ValueComponent(value: $0) }), multiline: true)))
    }
    
    mutating func addSingleLineArray(key: String?, children: [Component]) {
        arguments.append(.init(key: key, value: ArrayComponent(elements: children, multiline: false)))
    }
    
    mutating func addSingleLineArray(key: String?, children: [Any]) {
        arguments.append(.init(key: key, value: ArrayComponent(elements: children.map({ ValueComponent(value: $0) }), multiline: false)))
    }
    
    mutating func addArgument(key: String?, component: Component) {
        arguments.append(.init(key: key, value: component))
    }
    
    func render() -> String {
        var str = name + "("
        if linebreak {
            str += "\n"
            str += arguments.map({ $0.render().indentingEachLine() }).joined(separator: ",\n")
            str += "\n"
        } else {
            str += arguments.map({ $0.render() }).joined(separator: ", ")
        }
        str += ")"
        return str
    }
}

// MARK: - Extensions

private extension Sequence where Element == String {
    func quoted() -> [String] {
        return map { $0.quoted }
    }
}

private extension String {
    func prependingEachLine(with value: String) -> String {
        return split(separator: "\n").map({ value + $0 }).joined(separator: "\n")
    }
    func indentingEachLine() -> String {
        let singleIndent = "    "
        return prependingEachLine(with: singleIndent)
    }
}

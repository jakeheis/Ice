//
//  PackageWriter.swift
//  Core
//
//  Created by Jake Heiser on 9/24/17.
//

import SwiftCLI

public class PackageWriter {
    
    private let writer: PackageWriterImpl
    
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
    var package: ModernPackageData { get }
    var toolsVersion: SwiftToolsVersion { get }
    
    init(package: ModernPackageData, toolsVersion: SwiftToolsVersion)
    
    func canWrite() -> Bool
    func addSwiftLanguageVersions(to function: inout FunctionCallComponent)
}

extension PackageWriterImpl {
    
    func write(to out: WritableStream) throws {
        guard canWrite() else {
            throw IceError(message: "cannot write package in version \(toolsVersion); try a different tools version")
        }
        
        var function = FunctionCallComponent(name: "Package")
        addName(to: &function)
        addPkgConfig(to: &function)
        addProviders(to: &function)
        addProducts(to: &function)
        addDependencies(to: &function)
        addTargets(to: &function)
        addSwiftLanguageVersions(to: &function)
        addCLangaugeStandard(to: &function)
        addCxxLangaugeStandard(to: &function)
        
        out <<< """
        // swift-tools-version:\(toolsVersion)
        // Managed by ice
        
        import PackageDescription
        
        let package = \(function.render())
        """
    }
    
    func addName(to function: inout FunctionCallComponent) {
        function.addQuoted(key: "name", value: package.name)
    }
    
    func addPkgConfig(to function: inout FunctionCallComponent) {
        if let pkgConfig = package.pkgConfig {
            function.addQuoted(key: "pkgConfig", value: pkgConfig)
        }
    }
    
    func addProviders(to function: inout FunctionCallComponent) {
        guard let providers = package.providers, !providers.isEmpty else {
            return
        }
        function.addMultilineArray(key: "providers", children: providers.map { (provider) in
            return providerComponent(for: provider)
        })
    }
    
    func addProducts(to function: inout FunctionCallComponent) {
        if package.products.isEmpty {
            return
        }
        
        function.addMultilineArray(key: "products", children: package.products.map { (product) in
            let funcName: String
            switch product.type {
            case .executable: funcName = "executable"
            case .library(_): funcName = "library"
            }
            var prodFunc = FunctionCallComponent(staticMember: funcName)
            prodFunc.addQuoted(key: "name", value: product.name)
            if case let .library(libType) = product.type, libType != .automatic {
                prodFunc.addSimple(key: "type", value: "." + libType.rawValue)
            }
            prodFunc.addSingleLineArray(key: "targets", children: product.targets.quoted())
            return prodFunc
        })
    }
    
    func addDependencies(to function: inout FunctionCallComponent) {
        if package.dependencies.isEmpty {
            return
        }
        
        function.addMultilineArray(key: "dependencies", children: package.dependencies.map { (dependency) in
            var depFunction = FunctionCallComponent(staticMember: "package")
            switch dependency.requirement {
            case .localPackage:
                depFunction.addQuoted(key: "path", value: dependency.url)
            case .range, .branch, .exact, .revision:
                depFunction.addQuoted(key: "url", value: dependency.url)
            }
            
            switch dependency.requirement {
            case let .range(lowerBoundString, upperBoundString):
                guard let lowerBound = Version(lowerBoundString), let upperBound = Version(upperBoundString) else {
                        fatalError("impossible dependency requirement; invalid range specified")
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
            case let .branch(id):
                var idFunc = FunctionCallComponent(staticMember: "branch")
                idFunc.addQuoted(key: nil, value: id)
                depFunction.addArgument(key: nil, component: idFunc)
            case let .exact(id):
                var idFunc = FunctionCallComponent(staticMember: "exact")
                idFunc.addQuoted(key: nil, value: id)
                depFunction.addArgument(key: nil, component: idFunc)
            case let .revision(id):
                var idFunc = FunctionCallComponent(staticMember: "revision")
                idFunc.addQuoted(key: nil, value: id)
                depFunction.addArgument(key: nil, component: idFunc)
            case .localPackage: break
            }
            
            return depFunction
        })
    }
    
    func addTargets(to function: inout FunctionCallComponent) {
        if package.targets.isEmpty {
            function.addSingleLineArray(key: "targets", children: [])
        } else {
            function.addMultilineArray(key: "targets", children: package.targets.map { (target) in
                let functionName: String
                switch target.type {
                case .regular: functionName = "target"
                case .test: functionName = "testTarget"
                case .system: functionName = "systemLibrary"
                }
                
                var functionCall = FunctionCallComponent(staticMember: functionName)
                functionCall.addQuoted(key: "name", value: target.name)
                switch target.type {
                case .regular, .test:
                    functionCall.addSingleLineArray(key: "dependencies", children: target.dependencies.map({ $0.name.quoted }))
                case .system: break
                }
                if let path = target.path {
                    functionCall.addQuoted(key: "path", value: path)
                }
                switch target.type {
                case .system:
                    if let pkgConfig = target.pkgConfig {
                        functionCall.addQuoted(key: "pkgConfig", value: pkgConfig)
                    }
                    if let providers = target.providers {
                        functionCall.addMultilineArray(key: "providers", children: providers.map(providerComponent))
                    }
                case .regular, .test:
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
    
    func addCLangaugeStandard(to function: inout FunctionCallComponent) {
        if let standard = package.cLanguageStandard {
            let converted = standard.replacingOccurrences(of: ":", with: "_")
            function.addSimple(key: "cLanguageStandard", value: ".\(converted)")
        }
    }
    
    func addCxxLangaugeStandard(to function: inout FunctionCallComponent) {
        if let standard = package.cxxLanguageStandard {
            let converted = standard
                .replacingOccurrences(of: "c++", with: "cxx")
                .replacingOccurrences(of: "gnu++", with: "gnucxx")
            function.addSimple(key: "cxxLanguageStandard", value: ".\(converted)")
        }
    }
    
    private func providerComponent(for provider: Package.Provider) -> Component {
        var provFunc = FunctionCallComponent(staticMember: provider.name)
        provFunc.addSingleLineArray(key: nil, children: provider.values.quoted())
        return provFunc
    }
    
}

final class Version4_0Writer: PackageWriterImpl {
    
    let package: ModernPackageData
    let toolsVersion: SwiftToolsVersion
    
    init(package: ModernPackageData, toolsVersion: SwiftToolsVersion) {
        self.package = package
        self.toolsVersion = toolsVersion
    }
    
    func canWrite() -> Bool {
        let containsLocal = package.dependencies.contains { (dep) in
            if case .localPackage = dep.requirement {
                return true
            }
            return false
        }
        if containsLocal {
            return false
        }
        if package.targets.contains(where:  { $0.type == .system }) {
            return false
        }
        if package.swiftLanguageVersions?.contains(where: { Int($0) == nil }) == true {
            return false
        }
        return true
    }
    
    func addSwiftLanguageVersions(to function: inout FunctionCallComponent) {
        if let versions = package.swiftLanguageVersions {
            function.addSingleLineArray(key: "swiftLanguageVersions", children: versions)
        }
    }
    
}

final class Version4_2Writer: PackageWriterImpl {
    
    let package: ModernPackageData
    let toolsVersion: SwiftToolsVersion
    
    init(package: ModernPackageData, toolsVersion: SwiftToolsVersion) {
        self.package = package
        self.toolsVersion = toolsVersion
    }
    
    func canWrite() -> Bool {
        return true
    }
    
    func addSwiftLanguageVersions(to function: inout FunctionCallComponent) {
        if let versions = package.swiftLanguageVersions {
            var enumVersions: [String] = []
            for version in versions {
                if version == "3" {
                    enumVersions.append(".v3")
                } else if version == "4" {
                    enumVersions.append(".v4")
                } else if version == "4.2" {
                    enumVersions.append(".v4_2")
                } else {
                    enumVersions.append(".version(\"\(version)\")")
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

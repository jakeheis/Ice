//
//  PackageLoader.swift
//  IceKit
//
//  Created by Jake Heiser on 7/28/18.
//

import Foundation
import PathKit

struct PackageLoader {
    
    static func load(in path: Path) throws -> Package {
        let data = try SPM(directory: path).dumpPackage()
        return try load(from: data)
    }
    
    static func load(from data: Data) throws -> Package {
        if let v4_2 = try? JSONDecoder().decode(PackageV4_2.self, from: data) {
            return v4_2
        } else if let v4_0 = try? JSONDecoder().decode(PackageV4_0.self, from: data) {
            return v4_0.convertToModern()
        } else {
            throw IceError(message: "couldn't parse Package.swift")
        }
    }
    
    private init() {}

}

public typealias PackageV4_2 = Package

public struct PackageV4_0: Decodable {
    
    public let name: String
    public let pkgConfig: String?
    public let providers: [Package.Provider]?
    public let products: [Package.Product]
    public let dependencies: [Package.Dependency]
    public let targets: [Package.Target]
    public let swiftLanguageVersions: [Int]? // Changed
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    
    func convertToModern() -> PackageV4_2 {
        let newSwiftLanguageVersions: [String]?
        if let swiftLanguageVersions = swiftLanguageVersions {
            newSwiftLanguageVersions = swiftLanguageVersions.map(String.init)
        } else {
            newSwiftLanguageVersions = nil
        }
        return PackageV4_2(
            name: name,
            pkgConfig: pkgConfig,
            providers: providers,
            products: products,
            dependencies: dependencies,
            targets: targets,
            swiftLanguageVersions: newSwiftLanguageVersions,
            cLanguageStandard: cLanguageStandard,
            cxxLanguageStandard: cxxLanguageStandard
        )
    }
    
}



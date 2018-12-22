//
//  Fixtures.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

import Foundation
@testable import IceKit
import PathKit
import XCTest

private let coder: JSONEncoder = {
    let json = JSONEncoder()
    json.outputFormatting = .prettyPrinted
    return json
}()
func assertEqualCodings<T: Codable>(_ lhs: T, _ rhs: T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(String(data: try coder.encode(lhs), encoding: .utf8)!, String(data: try coder.encode(rhs), encoding: .utf8)!, file: file, line: line)
}

struct Fixtures {
    
    static let products: [Package.Product] = [
        .init(name: "exec", targets: ["MyLib"], type: .executable),
        .init(name: "Lib", targets: ["Core"], type: .library(.automatic)),
        .init(name: "Static", targets: ["MyLib"], type: .library(.static)),
        .init(name: "Dynamic", targets: ["Core"], type: .library(.dynamic)),
    ]
    
    static let dependencies: [Package.Dependency] = [
        .init(
            url: "https://github.com/jakeheis/SwiftCLI",
            requirement: .branch("swift4")
        ),
        .init(
            url: "https://github.com/jakeheis/Spawn",
            requirement: .exact("0.0.4")
        ),
        .init(
            url: "https://github.com/jakeheis/Flock",
            requirement: .revision("c57454ce053821d2fef8ad25d8918ae83506810c")
        ),
        .init(
            url: "https://github.com/jakeheis/FlockCLI",
            requirement: .range("4.1.0", "5.0.0")
        ),
        .init(
            url: "https://github.com/jakeheis/FileKit",
            requirement: .range("2.1.3", "2.2.0")
        ),
        .init(
            url: "https://github.com/jakeheis/Shout",
            requirement: .range("0.6.4", "0.6.8")
        )
    ]
    
    static let targets: [Package.Target] = [
        .init(name: "CLI", type: .regular, dependencies: [
            .byName("Core"),
            .product("FileKit", nil)
        ]),
        .init(name: "CLITests", type: .test, dependencies: [
            .target("CLI"),
            .byName("Core")
        ]),
        .init(name: "Core", type: .regular, dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
        .init(name: "Exclusive", type: .regular, dependencies: [
            .byName("Core"),
            .product("Flock", "Flock")
        ], sources: ["only.swift"], publicHeadersPath: "headers.h")
    ]
    
    static let providers: [Package.Provider] = [
        .init(name: "brew", values: ["libssh2"]),
        .init(name: "apt", values: ["libssh2-1-dev", "libssh2-2-dev"])
    ]
    
    static var package = ModernPackageData(
        name: "myPackage",
        pkgConfig: "config",
        providers: providers,
        products: products,
        dependencies: dependencies,
        targets: targets,
        swiftLanguageVersions: ["3", "4"],
        cLanguageStandard: "iso9899:199409",
        cxxLanguageStandard: "gnu++1z"
    )
    
    static var package4_2 = ModernPackageData(
        name: "myPackage",
        pkgConfig: "config",
        providers: providers,
        products: products,
        dependencies: dependencies + [
            .init(url: "/Projects/PathKit", requirement: .localPackage)
        ],
        targets: targets  + [
            .init(name: "Clibssh2", type: .system, dependencies: [], path: "aPath", exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: "pc", providers: Fixtures.providers)
        ],
        swiftLanguageVersions: ["3", "4", "4.2"],
        cLanguageStandard: "c90",
        cxxLanguageStandard: "c++03"
    )
    
    private init() {}
}

let mockConfig = Config(reformat: false, openAfterXc: false)

class MockRegistry: RegistryType {
    
    func get(_ name: String) -> RegistryEntry? {
        return nil
    }
    
}

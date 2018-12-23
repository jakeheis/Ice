//
//  Fixtures.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

@testable import IceKit

struct Fixtures {
    
    static let package4_0 = PackageDataV4_0(
        name: "myPackage",
        pkgConfig: "config",
        providers: [
            .init(name: "apt", values: ["first", "second"]),
            .init(name: "brew", values: ["this", "that"])
        ],
        products: [
            .init(name: "exec", product_type: "executable", targets: ["MyLib"], type: nil),
            .init(name: "Lib", product_type: "library", targets: ["Core"], type: nil),
            .init(name: "Static", product_type: "library", targets: ["MyLib"], type: "static"),
            .init(name: "Dynamic", product_type: "library", targets: ["Core"], type: "dynamic")
        ],
        dependencies: [
            .init(
                url: "https://github.com/jakeheis/SwiftCLI",
                requirement: .init(type: .branch, lowerBound: nil, upperBound: nil, identifier: "swift4")
            ),
            .init(
                url: "https://github.com/jakeheis/Spawn",
                requirement: .init(type: .exact, lowerBound: nil, upperBound: nil, identifier: "0.0.4")
            ),
            .init(
                url: "https://github.com/jakeheis/Flock",
                requirement: .init(type: .revision, lowerBound: nil, upperBound: nil, identifier: "c57454ce053821d2fef8ad25d8918ae83506810c")
            ),
            .init(
                url: "https://github.com/jakeheis/FlockCLI",
                requirement: .init(type: .range, lowerBound: "4.1.0", upperBound: "5.0.0", identifier: nil)
            ),
            .init(
                url: "https://github.com/jakeheis/FileKit",
                requirement: .init(type: .range, lowerBound: "2.1.3", upperBound: "2.2.0", identifier: nil)
            ),
            .init(
                url: "https://github.com/jakeheis/Shout",
                requirement: .init(type: .range, lowerBound: "0.6.4", upperBound: "0.6.8", identifier: nil)
            )
        ],
        targets: [
            .init(name: "CLI", isTest: false, dependencies: [
                .init(name: "Core", package: nil, type: .byname),
                .init(name: "FileKit", package: nil, type: .product)
            ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil),
            .init(name: "CLITests", isTest: true, dependencies: [
                .init(name: "CLI", package: nil, type: .target),
                .init(name: "Core", package: nil, type: .byname)
                ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil),
            .init(name: "Core", isTest: false, dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"], sources: nil, publicHeadersPath: nil),
            .init(name: "Exclusive", isTest: false, dependencies: [
                .init(name: "Core", package: nil, type: .byname),
                .init(name: "FlockKit", package: "Flock", type: .product)
            ], path: nil, exclude: [], sources: ["only.swift"], publicHeadersPath: "headers.h")
        ],
        swiftLanguageVersions: [3, 4],
        cLanguageStandard: "iso9899:199409",
        cxxLanguageStandard: "gnu++1z"
    )
    
    static let package4_2 = PackageDataV4_2(
        name: "myPackage",
        pkgConfig: "config",
        providers: [
            .init(name: "apt", values: ["first", "second"]),
            .init(name: "brew", values: ["this", "that"])
        ],
        products: [
            .init(name: "exec", product_type: "executable", targets: ["MyLib"], type: nil),
            .init(name: "Lib", product_type: "library", targets: ["Core"], type: nil),
            .init(name: "Static", product_type: "library", targets: ["MyLib"], type: "static"),
            .init(name: "Dynamic", product_type: "library", targets: ["Core"], type: "dynamic")
        ],
        dependencies: [
            .init(
                url: "https://github.com/jakeheis/SwiftCLI",
                requirement: .init(type: .branch, lowerBound: nil, upperBound: nil, identifier: "swift4")
            ),
            .init(
                url: "https://github.com/jakeheis/Spawn",
                requirement: .init(type: .exact, lowerBound: nil, upperBound: nil, identifier: "0.0.4")
            ),
            .init(
                url: "https://github.com/jakeheis/Flock",
                requirement: .init(type: .revision, lowerBound: nil, upperBound: nil, identifier: "c57454ce053821d2fef8ad25d8918ae83506810c")
            ),
            .init(
                url: "https://github.com/jakeheis/FlockCLI",
                requirement: .init(type: .range, lowerBound: "4.1.0", upperBound: "5.0.0", identifier: nil)
            ),
            .init(
                url: "https://github.com/jakeheis/FileKit",
                requirement: .init(type: .range, lowerBound: "2.1.3", upperBound: "2.2.0", identifier: nil)
            ),
            .init(
                url: "https://github.com/jakeheis/Shout",
                requirement: .init(type: .range, lowerBound: "0.6.4", upperBound: "0.6.8", identifier: nil)
            ),
            .init(
                url: "/Projects/PathKit",
                requirement: .init(type: .localPackage, lowerBound: nil, upperBound: nil, identifier: nil)
            )
        ],
        targets: [
            .init(name: "CLI", type: .regular, dependencies: [
                .init(name: "Core", package: nil, type: .byname),
                .init(name: "FileKit", package: nil, type: .product),
            ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: nil, providers: nil),
            .init(name: "CLITests", type: .test, dependencies: [
                .init(name: "CLI", package: nil, type: .target),
                .init(name: "Core", package: nil, type: .byname)
            ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: nil, providers: nil),
            .init(name: "Core", type: .regular, dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"], sources: nil, publicHeadersPath: nil, pkgConfig: nil, providers: nil),
            .init(name: "Exclusive", type: .regular, dependencies: [
                .init(name: "Core", package: nil, type: .byname),
                .init(name: "FlockKit", package: "Flock", type: .product)
            ], path: nil, exclude: [], sources: ["only.swift"], publicHeadersPath: "headers.h", pkgConfig: nil, providers: nil),
            .init(name: "Clibssh2", type: .system, dependencies: [], path: "aPath", exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: "pc", providers: [
                .init(name: "apt", values: ["third", "fourth"]),
                .init(name: "brew", values: ["over", "there"])
            ])
        ],
        swiftLanguageVersions: ["3", "4", "4.2"],
        cLanguageStandard: "iso9899:199409",
        cxxLanguageStandard: "gnu++1z"
    )
    
    static let package5_0 = PackageDataV5_0(
        name: "myPackage",
        pkgConfig: "config",
        providers: [
            .init(kind: .apt, values: ["first", "second"]),
            .init(kind: .brew, values: ["this", "that"])
        ],
        products: [
            .init(name: "exec", targets: ["MyLib"], type: .executable),
            .init(name: "Lib", targets: ["Core"], type: .library(.automatic)),
            .init(name: "Static", targets: ["MyLib"], type: .library(.static)),
            .init(name: "Dynamic", targets: ["Core"], type: .library(.dynamic)),
        ],
        dependencies: [
            .init(url: "https://github.com/jakeheis/SwiftCLI", requirement: .branch("swift4")),
            .init(url: "https://github.com/jakeheis/Spawn", requirement: .exact("0.0.4")),
            .init(url: "https://github.com/jakeheis/Flock", requirement: .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
            .init(url: "https://github.com/jakeheis/FlockCLI", requirement: .range("4.1.0", "5.0.0")),
            .init(url: "https://github.com/jakeheis/FileKit", requirement: .range("2.1.3", "2.2.0")),
            .init(url: "https://github.com/jakeheis/Shout", requirement: .range("0.6.4", "0.6.8")),
            .init(url: "/Projects/PathKit", requirement: .localPackage)
        ],
        targets: [
            .init(name: "CLI", type: .regular, dependencies: [.byName("Core"), .product("FileKit", nil)]),
            .init(name: "CLITests", type: .test, dependencies: [.target("CLI"), .byName("Core")]),
            .init(name: "Core", type: .regular, dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
            .init(name: "Exclusive", type: .regular, dependencies: [.byName("Core"), .product("FlockKit", "Flock")], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            .init(name: "Clibssh2", type: .system, dependencies: [], path: "aPath", pkgConfig: "pc", providers: [
                .init(kind: .apt, values: ["third", "fourth"]),
                .init(kind: .brew, values: ["over", "there"])
            ]),
            .init(name: "Settings", type: .regular, dependencies: [], settings: [
                .init(name: "define", tool: .c, condition: nil, value: ["FOO"]),
                .init(name: "headerSearchPath", tool: .cxx, condition: .init(config: "debug"), value: ["path"]),
                .init(name: "unsafeFlags", tool: .swift, condition: .init(platformNames: ["macos"]), value: ["f1", "f2"]),
                .init(name: "linkedLibrary", tool: .linker, condition: .init(config: "release", platformNames: ["linux"]), value: ["libz"])
            ])
        ],
        swiftLanguageVersions: ["3", "4", "4.2"],
        cLanguageStandard: "iso9899:199409",
        cxxLanguageStandard: "gnu++1z"
    )
    
    static let modernPackage: ModernPackageData = package5_0
    static let modernToolsVersion = SwiftToolsVersion.v5
    
    private init() {}
}

let mockConfig = Config(reformat: false, openAfterXc: false)

class MockRegistry: RegistryType {
    
    func get(_ name: String) -> RegistryEntry? {
        return nil
    }
    
}

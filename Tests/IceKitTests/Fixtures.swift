//
//  Fixtures.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

import Foundation
@testable import IceKit
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
    
    static let products: [PackageDataV4_2.Product] = [
        .init(name: "exec", product_type: "executable", targets: ["MyLib"], type: nil),
        .init(name: "Lib", product_type: "library", targets: ["Core"], type: nil),
        .init(name: "Static", product_type: "library", targets: ["MyLib"], type: "static"),
        .init(name: "Dynamic", product_type: "library", targets: ["Core"], type: "dynamic")
    ]
    
    static let dependencies: [PackageDataV4_2.Dependency] = [
        .init(
            url: "https://github.com/jakeheis/SwiftCLI",
            requirement: .init(
                type: .branch,
                lowerBound: nil,
                upperBound: nil,
                identifier: "swift4"
            )
        ),
        .init(
            url: "https://github.com/jakeheis/Spawn",
            requirement: .init(
                type: .exact,
                lowerBound: nil,
                upperBound: nil,
                identifier: "0.0.4"
            )
        ),
        .init(
            url: "https://github.com/jakeheis/Flock",
            requirement: .init(
                type: .revision,
                lowerBound: nil,
                upperBound: nil,
                identifier: "c57454ce053821d2fef8ad25d8918ae83506810c"
            )
        ),
        .init(
            url: "https://github.com/jakeheis/FlockCLI",
            requirement: .init(
                type: .range,
                lowerBound: "4.1.0",
                upperBound: "5.0.0",
                identifier: nil
            )
        ),
        .init(
            url: "https://github.com/jakeheis/FileKit",
            requirement: .init(
                type: .range,
                lowerBound: "2.1.3",
                upperBound: "2.2.0",
                identifier: nil
            )
        ),
        .init(
            url: "https://github.com/jakeheis/Shout",
            requirement: .init(
                type: .range,
                lowerBound: "0.6.4",
                upperBound: "0.6.8",
                identifier: nil
            )
        )
    ]
    
    static let targets: [PackageDataV4_2.Target] = [
        .init(name: "CLI", isTest: false, dependencies: [
            .init(name: "Core"),
            .init(name: "FileKit")
        ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil),
        .init(name: "CLITests", isTest: true, dependencies: [
            .init(name: "CLI"),
            .init(name: "Core")
        ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil),
        .init(name: "Core", isTest: false, dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"], sources: nil, publicHeadersPath: nil),
        .init(name: "Exclusive", isTest: false, dependencies: [
            .init(name: "Core"),
            .init(name: "Flock")
        ], path: nil, exclude: [], sources: ["only.swift"], publicHeadersPath: "headers.h")
    ]
    
    static let providers: [PackageDataV4_2.Provider] = [
        .init(name: "brew", values: ["libssh2"]),
        .init(name: "apt", values: ["libssh2-1-dev", "libssh2-2-dev"])
    ]
    
    static var package = PackageDataV4_2(
        name: "myPackage",
        pkgConfig: "config",
        providers: providers,
        products: products,
        dependencies: dependencies,
        targets: targets,
        swiftLanguageVersions: ["3", "4"],
        cLanguageStandard: "c90",
        cxxLanguageStandard: "c++03"
    )
    
    private init() {}
}

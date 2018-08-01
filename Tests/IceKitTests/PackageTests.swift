//
//  PackageTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

@testable import IceKit
import PathKit
import XCTest

class PackageTests: XCTestCase {
    
    static var allTests = [
        ("testAddProduct", testAddProduct),
        ("testRemoveProduct", testRemoveProduct),
        ("testAddDependency", testAddDependency),
        ("testUpdateDependency", testUpdateDependency),
        ("testRemoveDependency", testRemoveDependency),
        ("testAddTarget", testAddTarget),
        ("testDepend", testDepend),
        ("testRemoveTarget", testRemoveTarget),
    ]

    func testAddProduct() {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        package.addProduct(name: "MyCLI", type: .executable, targets: ["Target3"])
        package.addProduct(name: "MyLib", type: .dynamicLibrary, targets: ["Target4"])
        
        let expectedProducts = Fixtures.products + [
            .init(name: "MyCLI", product_type: "executable", targets: ["Target3"], type: nil),
            .init(name: "MyLib", product_type: "library", targets: ["Target4"], type: "dynamic")
        ]
        assertEqualCodings(package.products, expectedProducts)
    }
    
    func testRemoveProduct() throws {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        try package.removeProduct(name: "Static")
        
        var expectedProducts = Fixtures.products
        expectedProducts.remove(at: 2)
        assertEqualCodings(package.products, expectedProducts)
        
        XCTAssertThrowsError(try package.removeProduct(name: "not-real"))
    }
    
    func testAddDependency() {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        let ref = RepositoryReference(url: "https://github.com/jakeheis/SwiftCLI")
        package.addDependency(ref: ref, requirement: .init(version: Version(5, 2, 0)))
        
        let expectedDependencies = Fixtures.dependencies + [
            .init(url: "https://github.com/jakeheis/SwiftCLI", requirement: .init(type: .range, lowerBound: "5.2.0", upperBound: "6.0.0", identifier: nil))
        ]
        assertEqualCodings(package.dependencies, expectedDependencies)
    }
    
    func testUpdateDependency() throws {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        try package.updateDependency(dependency: Fixtures.dependencies[3], to: .init(type: .branch, lowerBound: nil, upperBound: nil, identifier: "master"))
        
        var expectedDependencies = Fixtures.dependencies
        expectedDependencies[3].requirement = .init(type: .branch, lowerBound: nil, upperBound: nil, identifier: "master")
        assertEqualCodings(package.dependencies, expectedDependencies)
    }
    
    func testRemoveDependency() throws {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        try package.removeDependency(named: "Flock")
        
        var expectedDependencies = Fixtures.dependencies
        expectedDependencies.remove(at: 2)
        assertEqualCodings(package.dependencies, expectedDependencies)
        
        var expectedTargets = Fixtures.targets
        expectedTargets[3].dependencies = [.init(name: "Core")]
        assertEqualCodings(package.targets, expectedTargets)
        
        XCTAssertThrowsError(try package.removeDependency(named: "not-real"))
    }
    
    func testAddTarget() {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        package.addTarget(name: "CoreTests", type: .test, dependencies: ["Core"])
        
        let expectedTargets = Fixtures.targets + [
            .init(name: "CoreTests", type: .test, dependencies: [.init(name: "Core")], path: nil, exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: nil, providers: nil)
        ]
        assertEqualCodings(package.targets, expectedTargets)
    }
    
    func testDepend() throws {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        try package.depend(target: "Core", on: "SwiftCLI")
        try package.depend(target: "Exclusive", on: "CLI")
        
        var expectedTargets = Fixtures.targets
        expectedTargets[2].dependencies = [.init(name: "SwiftCLI")]
        expectedTargets[3].dependencies += [.init(name: "CLI")]
        assertEqualCodings(package.targets, expectedTargets)
        
        XCTAssertThrowsError(try package.depend(target: "not-real", on: "SwiftCLI"))
    }
    
    func testRemoveTarget() throws {
        var package = Package(data: Fixtures.package, directory: Path.current, toolsVersion: .v4)
        
        try package.removeTarget(named: "Core")
        
        var expectedTargets = Fixtures.targets
        expectedTargets.remove(at: 2)
        expectedTargets[0].dependencies.removeFirst()
        expectedTargets[1].dependencies.remove(at: 1)
        expectedTargets[2].dependencies.removeFirst()
        assertEqualCodings(package.targets, expectedTargets)
        
        XCTAssertThrowsError(try package.removeTarget(named: "not-real"))
    }

}

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
    
    func testAddProduct() {
        var package = createPackage()
        
        package.addProduct(name: "MyCLI", type: .executable, targets: ["Target3"])
        package.addProduct(name: "MyLib", type: .library(.dynamic), targets: ["Target4"])
        
        let expectedProducts = Fixtures.products + [
            .init(name: "MyCLI", targets: ["Target3"], type: .executable),
            .init(name: "MyLib", targets: ["Target4"], type: .library(.dynamic))
        ]
        assertEqualCodings(package.products, expectedProducts)
    }
    
    func testRemoveProduct() throws {
        var package = createPackage()
        
        try package.removeProduct(name: "Static")
        
        var expectedProducts = Fixtures.products
        expectedProducts.remove(at: 2)
        assertEqualCodings(package.products, expectedProducts)
        
        XCTAssertThrowsError(try package.removeProduct(name: "not-real"))
    }
    
    func testAddDependency() {
        var package = createPackage()
        
        let ref = RepositoryReference(url: "https://github.com/jakeheis/SwiftCLI")
        package.addDependency(ref: ref, requirement: .init(version: Version(5, 2, 0)))
        
        let expectedDependencies = Fixtures.dependencies + [
            .init(url: "https://github.com/jakeheis/SwiftCLI", requirement: .range("5.2.0", "6.0.0"))
        ]
        assertEqualCodings(package.dependencies, expectedDependencies)
    }
    
    func testUpdateDependency() throws {
        var package = createPackage()
        
        try package.updateDependency(dependency: Fixtures.dependencies[3], to: .branch("master"))
        
        var expectedDependencies = Fixtures.dependencies
        expectedDependencies[3].requirement = .branch("master")
        assertEqualCodings(package.dependencies, expectedDependencies)
    }
    
    func testRemoveDependency() throws {
        var package = createPackage()
        
        try package.removeDependency(named: "Flock")
        
        var expectedDependencies = Fixtures.dependencies
        expectedDependencies.remove(at: 2)
        assertEqualCodings(package.dependencies, expectedDependencies)
        
        var expectedTargets = Fixtures.targets
        expectedTargets[3].dependencies = [.byName("Core")]
        assertEqualCodings(package.targets, expectedTargets)
        
        XCTAssertThrowsError(try package.removeDependency(named: "not-real"))
    }
    
    func testAddTarget() {
        var package = createPackage()
        
        package.addTarget(name: "CoreTests", type: .test, dependencies: ["Core"])
        
        let expectedTargets = Fixtures.targets + [
            .init(name: "CoreTests", type: .test, dependencies: [.byName("Core")], path: nil, exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: nil, providers: nil)
        ]
        assertEqualCodings(package.targets, expectedTargets)
    }
    
    func testDepend() throws {
        var package = createPackage()
        
        try package.depend(target: "Core", on: "SwiftCLI")
        try package.depend(target: "Exclusive", on: "CLI")
        
        var expectedTargets = Fixtures.targets
        expectedTargets[2].dependencies = [.byName("SwiftCLI")]
        expectedTargets[3].dependencies += [.byName("CLI")]
        assertEqualCodings(package.targets, expectedTargets)
        
        XCTAssertThrowsError(try package.depend(target: "not-real", on: "SwiftCLI"))
    }
    
    func testRemoveTarget() throws {
        var package = createPackage()
        
        try package.removeTarget(named: "Core")
        
        var expectedTargets = Fixtures.targets
        expectedTargets.remove(at: 2)
        expectedTargets[0].dependencies.removeFirst()
        expectedTargets[1].dependencies.remove(at: 1)
        expectedTargets[2].dependencies.removeFirst()
        assertEqualCodings(package.targets, expectedTargets)
        
        XCTAssertThrowsError(try package.removeTarget(named: "not-real"))
    }
    
    private func createPackage() -> Package {
        return Package(data: Fixtures.package, toolsVersion: .v4, directory: .current, config: mockConfig)
    }

}

//
//  PackageTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

@testable import IceKit
import PathKit
import TestingUtilities
import XCTest

class PackageTests: XCTestCase {
    
    func testAddProduct() {
        var package = createPackage()
        
        package.addProduct(name: "MyCLI", targets: ["Target3"], type: .executable)
        package.addProduct(name: "MyLib", targets: ["Target4"], type: .library(.dynamic))
        
        var expectedPackage = Fixtures.modernPackage
        expectedPackage.products += [
            .init(name: "MyCLI", targets: ["Target3"], type: .executable),
            .init(name: "MyLib", targets: ["Target4"], type: .library(.dynamic))
        ]
        IceAssertEqual(package.data, expectedPackage)
    }
    
    func testRemoveProduct() throws {
        var package = createPackage()
        
        guard let product = package.getProduct(named: "Static") else {
            XCTFail()
            return
        }
        
        package.removeProduct(product)
        
        var expectedPackage = Fixtures.modernPackage
        expectedPackage.products.remove(at: 2)
        IceAssertEqual(package.data, expectedPackage)
    }
    
    func testAddDependency() {
        var package = createPackage()
        
        package.addDependency(url: "https://github.com/jakeheis/SwiftCLI", requirement: .init(from: Version(5, 2, 0)))
        
        var expectedPackage = Fixtures.modernPackage
        expectedPackage.dependencies.append(.init(url: "https://github.com/jakeheis/SwiftCLI", requirement: .range("5.2.0", "6.0.0")))
        IceAssertEqual(package.data, expectedPackage)
    }
    
    func testUpdateDependency() throws {
        var package = createPackage()
        
        try package.updateDependency(dependency: Fixtures.modernPackage.dependencies[3], to: .branch("master"))
        
        var expectedPackage = Fixtures.modernPackage
        expectedPackage.dependencies[3].requirement = .branch("master")
        IceAssertEqual(package.data, expectedPackage)
    }
    
    func testRemoveDependency() throws {
        var package = createPackage()
        
        guard let dependency = package.getDependency(named: "Flock") else {
            XCTFail()
            return
        }
        
        package.removeDependency(dependency)
        
        var expectedDependencies = Fixtures.modernPackage.dependencies
        expectedDependencies.remove(at: 2)
        XCTAssertEqual(package.dependencies, expectedDependencies)
        
        var expectedTargets = Fixtures.modernPackage.targets
        expectedTargets[3].dependencies = [.byName("Core")]
        
        XCTAssertEqual(package.targets, expectedTargets)
        IceAssertEqual(package.targets[0], expectedTargets[0])
        IceAssertEqual(package.targets[1], expectedTargets[1])
        IceAssertEqual(package.targets[2], expectedTargets[2])
        IceAssertEqual(package.targets[3], expectedTargets[3])
    }
    
    func testAddTarget() {
        var package = createPackage()
        
        package.addTarget(name: "CoreTests", type: .test, dependencies: [.byName("Core")])
        
        var expectedPackage = Fixtures.modernPackage
        expectedPackage.targets.append(.init(name: "CoreTests", type: .test, dependencies: [.byName("Core")]))
        IceAssertEqual(package.data, expectedPackage)
    }
    
    func testDepend() throws {
        var package = createPackage()
        
        guard let core = package.getTarget(named: "Core"), let exclusive = package.getTarget(named: "Exclusive") else {
            XCTFail()
            return
        }
        
        try package.addTargetDependency(for: core, on: .byName("SwiftCLI"))
        try package.addTargetDependency(for: exclusive, on: .target("CLI"))
        
        var expectedPackage = Fixtures.modernPackage
        expectedPackage.targets[2].dependencies = [.byName("SwiftCLI")]
        expectedPackage.targets[3].dependencies += [.target("CLI")]
        IceAssertEqual(package.data, expectedPackage)
    }
    
    func testRemoveTarget() throws {
        var package = createPackage()
        
        guard let core = package.getTarget(named: "Core") else {
            XCTFail()
            return
        }
        
        package.removeTarget(core)
        
        var expectedPackage = Fixtures.modernPackage
        expectedPackage.targets.remove(at: 2)
        expectedPackage.targets[0].dependencies.removeFirst()
        expectedPackage.targets[1].dependencies.remove(at: 1)
        expectedPackage.targets[2].dependencies.removeFirst()
        
        IceAssertEqual(package.data, expectedPackage)
        IceAssertEqual(package.data.targets[0], expectedPackage.targets[0])
        IceAssertEqual(package.data.targets[1], expectedPackage.targets[1])
        IceAssertEqual(package.data.targets[2], expectedPackage.targets[2])
    }
    
    private func createPackage() -> Package {
        return Package(data: Fixtures.modernPackage, toolsVersion: Fixtures.modernToolsVersion, path: .current + "Package.swift", config: mockConfig)
    }

}

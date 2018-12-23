//
//  PackageDataTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

@testable import IceKit
import XCTest

class PackageDataTests: XCTestCase {
    
    func testModernize4_0() throws {
        let modernized = Fixtures.package4_0.convertToModern()
        
        var expected = Fixtures.package5_0
        expected.targets.removeLast() // Remove settings target
        expected.targets.removeLast() // Remove system target
        expected.dependencies.removeLast() // Remove local dependency
        expected.swiftLanguageVersions?.removeLast() // Remove non-integer version
        
        XCTAssertEqual(modernized, expected)
    }
    
    func testModernize4_2() {
        let modernized = Fixtures.package4_2.convertToModern()
        
        var expected = Fixtures.package5_0
        expected.targets.removeLast() // Remove settings target
        
        XCTAssertEqual(modernized, expected)
    }

    func testSwiftToolsVersion() {
        let fourTwo = SwiftToolsVersion(major: 4, minor: 2, patch: 0)
        
        XCTAssertEqual(fourTwo, .v4_2)
        XCTAssertNotEqual(fourTwo, .v4)
        
        XCTAssertGreaterThan(fourTwo, .v4)
        
        XCTAssertEqual(fourTwo.description, "4.2")
        XCTAssertEqual(fourTwo, SwiftToolsVersion("4.2.0"))
        XCTAssertEqual(fourTwo, SwiftToolsVersion("4.2"))
    }
    
}

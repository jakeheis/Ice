//
//  VersionTests.swift
//  CoreTests
//
//  Created by Jake Heiser on 9/20/17.
//

import IceKit
import XCTest

class VersionTests: XCTestCase {
    
    func testBasicParse() {
        let version = Version("1.4.3")
        XCTAssertEqual(version?.major, 1)
        XCTAssertEqual(version?.minor, 4)
        XCTAssertEqual(version?.patch, 3)
    }
    
    func testVParse() {
        let version = Version("v1.4.3")
        XCTAssertEqual(version?.major, 1)
        XCTAssertEqual(version?.minor, 4)
        XCTAssertEqual(version?.patch, 3)
    }
    
    func testIllegalVersion() {
        XCTAssertNil(Version("1,4.3"))
    }
    
    func testEquality() {
        XCTAssertEqual(Version("1.4.3"), Version(1, 4, 3))
    }
    
    func testComparison() {
        let v1 = Version(0, 5, 3)
        let v2 = Version(0, 8, 1)
        let v3 = Version(0, 12, 5)
        let v4 = Version(1, 0, 0)
        let v5 = Version(1, 0, 1)
        
        XCTAssertLessThan(v1, v2)
        XCTAssertLessThan(v1, v3)
        XCTAssertLessThan(v1, v4)
        XCTAssertLessThan(v1, v5)
        
        XCTAssertLessThan(v2, v3)
        XCTAssertLessThan(v2, v4)
        XCTAssertLessThan(v2, v5)
        
        XCTAssertLessThan(v3, v4)
        XCTAssertLessThan(v3, v5)
        
        XCTAssertLessThan(v4, v5)
    }
    
}

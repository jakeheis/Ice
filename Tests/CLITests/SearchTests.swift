//
//  SearchTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class SearchTests: XCTestCase {
    
    static var allTests = [
        ("testFullSearch", testFullSearch),
        ("testNameSearch", testNameSearch),
        ("testNoResults", testNoResults),
    ]
    
    func testFullSearch() {
        let result = Runner.execute(args: ["search", "RxSwift"])
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        
        ● Name: RxSwift
          URL: https://github.com/ReactiveX/RxSwift
          Description: Reactive Programming in Swift

        ● Name: RxDataSources
          URL: https://github.com/RxSwiftCommunity/RxDataSources
          Description: UITableView and UICollectionView Data Sources for RxSwift (sections, animated updates, editing ...)

        ● Name: RxAutomaton
          URL: https://github.com/inamiy/RxAutomaton
          Description: RxSwift + State Machine, inspired by Redux and Elm.
        
        
        """)
    }
    
    func testNameSearch() {
        let result = Runner.execute(args: ["search", "RxSwift", "-n"])
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        
        ● Name: RxSwift
          URL: https://github.com/ReactiveX/RxSwift
          Description: Reactive Programming in Swift
        
        
        """)
    }
    
    func testNoResults() {
        let result = Runner.execute(args: ["search", "NotRealPackage", "-n"])
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Warning: no results found
        
        Try a Github search: https://github.com/search?q=NotRealPackage+language:swift&s=stars
        
        
        """)
    }
    
}

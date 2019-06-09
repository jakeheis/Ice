//
//  SearchTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class SearchTests: XCTestCase {
    
    func testFullSearch() {
        let result = IceBox(template: .empty).run("search", "RxSwift")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout!, """
        
        ● Name: RxSwift
          URL: https://github.com/ReactiveX/RxSwift
          Description: Reactive Programming in Swift

        ● Name: RxDataSources
          URL: https://github.com/RxSwiftCommunity/RxDataSources
          Description: UITableView and UICollectionView Data Sources for RxSwift (sections, animated updates, editing ...)

        ● Name: RxAutomaton
          URL: https://github.com/inamiy/RxAutomaton
          Description: RxSwift + State Machine, inspired by Redux and Elm.

        ● Name: RxFeedback.swift
          URL: https://github.com/NoTests/RxFeedback.swift
          Description: Architecture for RxSwift

        ● Name: RxAlamofire
          URL: https://github.com/RxSwiftCommunity/RxAlamofire
          Description: RxSwift wrapper around the elegant HTTP networking in Swift Alamofire

        ● Name: RxBluetoothKit
          URL: https://github.com/Polidea/RxBluetoothKit
          Description: iOS & OSX Bluetooth library for RxSwift
        
        ● Name: Action
          URL: https://github.com/RxSwiftCommunity/Action
          Description: Abstracts actions to be performed in RxSwift.

        
        """)
    }
    
    func testNameSearch() {
        let result = IceBox(template: .empty).run("search", "RxSwift", "-n")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        
        ● Name: RxSwift
          URL: https://github.com/ReactiveX/RxSwift
          Description: Reactive Programming in Swift
        
        
        """)
    }
    
    func testNoResults() {
        let result = IceBox(template: .empty).run("search", "NotRealPackage", "-n")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Warning: no results found
        
        Try a Github search: https://github.com/search?q=NotRealPackage+language:swift&s=stars
        
        
        """)
    }
    
}

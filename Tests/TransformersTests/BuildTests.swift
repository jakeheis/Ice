//
//  BuildTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

import XCTest
import Exec
@testable import Transformers

class BuildTests: XCTestCase {
    
    static var allTests = [
        ("testCompile", testCompile),
        ("testCompileC", testCompileC),
        ("testLink", testLink),
        ("testError", testError),
        ("testWarningWithSingleNote", testWarningWithSingleNote),
        ("testNoteNoCode", testNoteNoCode),
        ("testSuggestion", testSuggestion),
        ("testRepeated", testRepeated),
    ]
    
    override func setUp() {
        ErrorTracker.past = []
    }
    
    func testCompile() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        Compile Swift Module 'Sup' (1 sources)
        """)
        build.expect(stdout: """
        Compile Sup (1 sources)

        """, stderr: "")
    }
    
    func testCompileC() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        Compile RxCocoaRuntime _RXDelegateProxy.m
        Compile RxCocoaRuntime _RXKVOObserver.m
        Compile RxCocoaRuntime _RXObjCRuntime.m
        """)
        build.expect(stdout: """
        Compile RxCocoaRuntime

        """, stderr: "")
    }
    
    func testLink() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        Linking ./.build/x86_64-apple-macosx10.10/debug/ice
        """)
        build.expect(stdout: """
        Link ./.build/x86_64-apple-macosx10.10/debug/ice

        """, stderr: "")
    }
    
    func testError() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        /Ice/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        """)
        build.expect(stdout: """
        
          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let arg: Int = ""
                           ^^
            at /Ice/Sources/Exec/Exec.swift:19

        
        """, stderr: "")
    }
    
    func testWarningWithSingleNote() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        /Moya/.build/checkouts/ReactiveSwift.git/Sources/UnidirectionalBinding.swift:23:17: warning: redeclaration of associated type 'Value' from protocol 'SignalProducerConvertible' is better expressed as a 'where' clause on the protocol
        associatedtype Value
        ~~~~~~~~~~~~~~~^~~~~

        /Moya/.build/checkouts/ReactiveSwift.git/Sources/SignalProducer.swift:307:17: note: 'Value' declared here
        associatedtype Value
        ^
        """)
        build.expect(stdout: """
        
          ● Warning: redeclaration of associated type 'Value' from protocol 'SignalProducerConvertible' is better expressed as a 'where' clause on the protocol
        
            associatedtype Value
            ^^^^^^^^^^^^^^^^^^^^
            at /Moya/.build/checkouts/ReactiveSwift.git/Sources/UnidirectionalBinding.swift:23

            Note: 'Value' declared here

            associatedtype Value
            ^
            at /Moya/.build/checkouts/ReactiveSwift.git/Sources/SignalProducer.swift:307


        """, stderr: "")
    }
    
    func testNoteNoCode() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314:61: warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]
                                                              error:error];
                                                                    ^
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297:102: note: declare the parameter __strong or capture a __block __strong variable to keep values alive across autorelease pools
        """)
        build.expect(stdout: """
        
          ● Warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]

            error:error];
                  ^
            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314

            Note: declare the parameter __strong or capture a __block __strong variable to keep values alive across autorelease pools

            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297


        """, stderr: "")
    }
    
    func testNoteOtherModule() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        /FlockCLI/Sources/FlockCLI/InitCommand.swift:93:23: error: 'CLIError' is unavailable: use CLI.Error instead
                throw CLIError.error("Couldn't open .gitignore stream")
                      ^~~~~~~~
        SwiftCLI.CLIError:2:13: note: 'CLIError' has been explicitly marked unavailable here
        public enum CLIError : Error {
                    ^
        """)
        build.expect(stdout: """

          ● Error: 'CLIError' is unavailable: use CLI.Error instead

            throw CLIError.error("Couldn't open .gitignore stream")
                  ^^^^^^^^
            at /FlockCLI/Sources/FlockCLI/InitCommand.swift:93

            Note: 'CLIError' has been explicitly marked unavailable here

            public enum CLIError : Error {
                        ^
            at SwiftCLI.CLIError:2


        """, stderr: "")
    }
    
    func testSuggestion() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314:61: warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]
                                                              error:error];
                                                                    ^
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297:102: note: declare the parameter __autoreleasing explicitly to suppress this warning
        IMP __nullable RX_ensure_observing(id __nonnull target, SEL __nonnull selector, NSError ** __nonnull error) {
                                                                                                             ^
                                                                                                  __autoreleasing
        """)
        
        build.expect(stdout: """
        
          ● Warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]

            error:error];
                  ^
            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314

            Note: declare the parameter __autoreleasing explicitly to suppress this warning

            IMP __nullable RX_ensure_observing(id __nonnull target, SEL __nonnull selector, NSError ** __nonnull error) {
                                                                                                                 ^
                                                                                                      __autoreleasing
        
            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297


        """, stderr: "")
    }
    
    func testRepeated() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        /Ice/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        /Ice/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        """)
        build.expect(stdout: """
        
          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let arg: Int = ""
                           ^^
            at /Ice/Sources/Exec/Exec.swift:19

        
        """, stderr: "")
    }
    
}

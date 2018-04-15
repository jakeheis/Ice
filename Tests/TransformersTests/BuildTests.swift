//
//  BuildTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

import XCTest
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
        ("testPackageError", testPackageError)
    ]
    
    func testCompile() {
        let build = createTest()
        build.send("""
        Compile Swift Module 'Sup' (1 sources)
        """)
        build.expect("""
        Compile Sup (1 sources)

        """)
    }
    
    func testCompileC() {
        let build = createTest()
        build.send("""
        Compile RxCocoaRuntime _RXDelegateProxy.m
        Compile RxCocoaRuntime _RXKVOObserver.m
        Compile RxCocoaRuntime _RXObjCRuntime.m
        """)
        build.expect("""
        Compile RxCocoaRuntime

        """)
    }
    
    func testLink() {
        let build = createTest()
        build.send("""
        Linking ./.build/x86_64-apple-macosx10.10/debug/ice
        """)
        build.expect("""
        Link ./.build/x86_64-apple-macosx10.10/debug/ice

        """)
    }
    
    func testError() {
        let build = createTest()
        build.send("""
        /Ice/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        """)
        build.expect("""
        
          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let arg: Int = ""
                           ^^
            at /Ice/Sources/Exec/Exec.swift:19

        
        """)
    }
    
    func testWarningWithSingleNote() {
        let build = createTest()
        build.send("""
        /Moya/.build/checkouts/ReactiveSwift.git/Sources/UnidirectionalBinding.swift:23:17: warning: redeclaration of associated type 'Value' from protocol 'SignalProducerConvertible' is better expressed as a 'where' clause on the protocol
        associatedtype Value
        ~~~~~~~~~~~~~~~^~~~~

        /Moya/.build/checkouts/ReactiveSwift.git/Sources/SignalProducer.swift:307:17: note: 'Value' declared here
        associatedtype Value
        ^
        """)
        build.expect("""
        
          ● Warning: redeclaration of associated type 'Value' from protocol 'SignalProducerConvertible' is better expressed as a 'where' clause on the protocol
        
            associatedtype Value
            ^^^^^^^^^^^^^^^^^^^^
            at /Moya/.build/checkouts/ReactiveSwift.git/Sources/UnidirectionalBinding.swift:23

            Note: 'Value' declared here

            associatedtype Value
            ^
            at /Moya/.build/checkouts/ReactiveSwift.git/Sources/SignalProducer.swift:307


        """)
    }
    
    func testNoteNoCode() {
        let build = createTest()
        build.send("""
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314:61: warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]
                                                              error:error];
                                                                    ^
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297:102: note: declare the parameter __strong or capture a __block __strong variable to keep values alive across autorelease pools
        """)
        build.expect("""
        
          ● Warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]

            error:error];
                  ^
            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314

            Note: declare the parameter __strong or capture a __block __strong variable to keep values alive across autorelease pools

            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297


        """)
    }
    
    func testNoteOtherModule() {
        let build = createTest()
        build.send("""
        /FlockCLI/Sources/FlockCLI/InitCommand.swift:93:23: error: 'CLIError' is unavailable: use CLI.Error instead
                throw CLIError.error("Couldn't open .gitignore stream")
                      ^~~~~~~~
        SwiftCLI.CLIError:2:13: note: 'CLIError' has been explicitly marked unavailable here
        public enum CLIError : Error {
                    ^
        """)
        build.expect("""

          ● Error: 'CLIError' is unavailable: use CLI.Error instead

            throw CLIError.error("Couldn't open .gitignore stream")
                  ^^^^^^^^
            at /FlockCLI/Sources/FlockCLI/InitCommand.swift:93

            Note: 'CLIError' has been explicitly marked unavailable here

            public enum CLIError : Error {
                        ^
            at SwiftCLI.CLIError:2


        """)
    }
    
    func testSuggestion() {
        let build = createTest()
        build.send("""
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314:61: warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]
                                                              error:error];
                                                                    ^
        /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297:102: note: declare the parameter __autoreleasing explicitly to suppress this warning
        IMP __nullable RX_ensure_observing(id __nonnull target, SEL __nonnull selector, NSError ** __nonnull error) {
                                                                                                             ^
                                                                                                  __autoreleasing
        """)
        
        build.expect("""
        
          ● Warning: block captures an autoreleasing out-parameter, which may result in use-after-free bugs [-Wblock-capture-autoreleasing]

            error:error];
                  ^
            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:314

            Note: declare the parameter __autoreleasing explicitly to suppress this warning

            IMP __nullable RX_ensure_observing(id __nonnull target, SEL __nonnull selector, NSError ** __nonnull error) {
                                                                                                                 ^
                                                                                                      __autoreleasing
        
            at /Moya/.build/checkouts/RxSwift.git/Sources/RxCocoaRuntime/_RXObjCRuntime.m:297


        """)
    }
    
    func testRepeated() {
        let build = createTest()
        build.send("""
        /Ice/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        /Ice/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        """)
        build.expect("""
        
          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let arg: Int = ""
                           ^^
            at /Ice/Sources/Exec/Exec.swift:19

        
        """)
    }
    
    func testPackageError() {
        let build = TransformerTest(transformer: BuildErr(), isStdout: false)
        build.send("'Project' /Dir: error: could not find target(s): Project; use the 'path' property in the Swift 4 manifest to set a custom target path")
        build.expect("""
        
        Error: could not find target(s): Project; use the 'path' property in the Swift 4 manifest to set a custom target path

        
        """)
    }
    
    func testPCHError() {
        let build = createTest()
        build.send("""
        Compile Swift Module 'foo' (1 sources)
        <unknown>:0: error: PCH was compiled with module cache path '/foo/.build/x86_64-apple-macosx10.10/debug/ModuleCache/F6Q938U2LW28', but the path is currently '/bar/.build/x86_64-apple-macosx10.10/debug/ModuleCache/F6Q938U2LW28'
        <unknown>:0: error: missing required module 'SwiftShims'
        """)
        build.expect("""
        Compile foo (1 sources)

          ● Error: PCH was compiled with module cache path '/foo/.build/x86_64-apple-macosx10.10/debug/ModuleCache/F6Q938U2LW28', but the path is currently '/bar/.build/x86_64-apple-macosx10.10/debug/ModuleCache/F6Q938U2LW28'


          ● Error: missing required module 'SwiftShims'

        
        """)
    }
    
    private func createTest() -> TransformerTest {
        return TransformerTest(transformer: BuildOut(), isStdout: true)
    }
    
}

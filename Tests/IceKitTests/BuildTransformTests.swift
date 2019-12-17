//
//  BuildTransformTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/16/17.
//

@testable import IceKit
import XCTest

class BuildTransformTests: XCTestCase {
    
    func testCompile() {
        let build = createTest()
        build.send("""
        Compile Swift Module 'Sup' (1 sources)
        """)
        build.expect("""
        Compile Sup (1 sources)

        """)
        
        let build5 = createTest()
        build5.send("""
        [1/10] Compiling Swift Module 'Sup' (1 sources)
        """)
        build5.expect("""
        Compile Sup (1 sources)

        """)
        
        let build5_1 = createTest()
        build5_1.send("""
        [1/24] Compiling SwiftCLI ParameterFiller.swift
        [2/24] Compiling SwiftCLI Path.swift
        [3/24] Compiling OtherModule Path.swift
        [4/24] Compiling SwiftCLI Path.swift
        """)
        build5_1.expect("""
        Compile SwiftCLI
        Compile OtherModule

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
        
        let build5 = createTest()
        build5.send("""
        [1/10] Compiling RxCocoaRuntime _RXObjCRuntime.m
        [2/10] Compiling RxCocoaRuntime _RXKVOObserver.m
        [3/10] Compiling RxCocoaRuntime _RXDelegateProxy.m
        """)
        build5.expect("""
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
        
        let build5 = createTest()
        build5.send("""
        [10/10] Linking ./.build/x86_64-apple-macosx/debug/ice
        """)
        build5.expect("""
        Link ./.build/x86_64-apple-macosx/debug/ice

        """)
    }
    
    func testMerge() {
        let merge = createTest()
        merge.send("""
        [23/25] Compiling SwiftCLI file.swift
        [24/25] Merging module Other
        [24/25] Merging module SwiftCLI
        """)
        merge.expect("""
        Compile SwiftCLI
        Compile Other

        """)
    }
    
    func testError() {
        let build = createTest()
        build.send("""
        /IceIce/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        """)
        build.expect("""
        
          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let arg: Int = ""
                           ^^
            at /IceIce/Sources/Exec/Exec.swift:19

        
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
        /IceIce/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        /IceIce/Sources/Exec/Exec.swift:19:24: error: cannot convert value of type 'String' to specified type 'Int'
                let arg: Int = ""
                               ^~
        """)
        build.expect("""
        
          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let arg: Int = ""
                           ^^
            at /IceIce/Sources/Exec/Exec.swift:19

        
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
    
    func testUnusedWarning() {
        let build = TransformerTest(transformer: BuildErr(), isStdout: false)
        build.send("warning: dependency 'SwiftCLI' is not used by any target")
        build.expect("""
        
        Warning: dependency 'SwiftCLI' is not used by any target

        
        """)
    }
    
    func testLinkerError() {
        let build = createTest()
        build.send("""
        Linking ./.build/x86_64-apple-macosx10.10/debug/IcePackageTests.xctest/Contents/MacOS/IcePackageTests
        Undefined symbols for architecture x86_64:
          "__T08SwiftCLI10PipeStreamC04readD0AA04ReadD0CvpWvd", referenced from:
              __T06IceKit15TransformerPairC12createStream33_79BB931AD0437A76696F68B8086A823ALL8SwiftCLI08WritableF0_pAA04BaseC0_p11transformer_tFyycfU_ in Transformer.swift.o
          "__T08SwiftCLI10PipeStreamCAA08ReadableD0AAWP", referenced from:
        ld: symbol(s) not found for architecture x86_64
        <unknown>:0: error: link command failed with exit code 1 (use -v to see invocation)
        """)
        build.expect("""
        Link ./.build/x86_64-apple-macosx10.10/debug/IcePackageTests.xctest/Contents/MacOS/IcePackageTests
        Undefined symbols for architecture x86_64:
          "__T08SwiftCLI10PipeStreamC04readD0AA04ReadD0CvpWvd", referenced from:
              __T06IceKit15TransformerPairC12createStream33_79BB931AD0437A76696F68B8086A823ALL8SwiftCLI08WritableF0_pAA04BaseC0_p11transformer_tFyycfU_ in Transformer.swift.o
          "__T08SwiftCLI10PipeStreamCAA08ReadableD0AAWP", referenced from:
        ld: symbol(s) not found for architecture x86_64

          ● Error: link command failed with exit code 1 (use -v to see invocation)

        
        """)
    }
    
    private func createTest() -> TransformerTest {
        return TransformerTest(transformer: BuildOut(), isStdout: true)
    }
    
}

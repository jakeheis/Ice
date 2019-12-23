//
// TestingUtilities.swift
// Ice
//

import Foundation
import Icebox
import XCTest

public class IceConfig: IceboxConfig {
    
    public enum Templates: String {
        case empty
        case lib
        case exec
        case json
    }
    
    public static let executable = "ice"
    
    public static func configure(process: Process) {
        var env = ProcessInfo.processInfo.environment
        env["ICE_GLOBAL_ROOT"] = "global"
        process.environment = env
    }
    
}

public typealias IceBox = Icebox<IceConfig>

public typealias Assertion = () -> ()

public class Differentiate {
    
    public static func byPlatform(mac: Assertion, linux: Assertion) {
        differentiate.byPlatform(mac: mac, linux: linux)
    }
    
    public static func byVersion(swift5_1AndAbove: Assertion) {
        differentiate.byVersion(swift5_1AndAbove: swift5_1AndAbove)
    }
    
    private static let differentiate = Differentiate()
    
    private init() {
        let platform: String
        #if os(macOS)
        platform = "macOS"
        #else
        platform = "Linux"
        #endif
        
        let version: String = "5.1 (and above)"
        
        print()
        print("Differentiate: running tests on \(platform), Swift version \(version)")
        print()
    }
    
    private func byPlatform(mac: Assertion, linux: Assertion) {
        #if os(macOS)
        mac()
        #else
        linux()
        #endif
    }
    
    private func byVersion(swift5_1AndAbove: Assertion) {
        swift5_1AndAbove()
    }
    
}

public func IceAssertEqual<T: Equatable>(_ first: T?, _ second: T?, file: StaticString = #file, line: UInt = #line) {
    if let firstValue = first, let secondValue = second {
        XCTAssertEqual(firstValue, secondValue, file: file, line: line)
    } else {
        XCTAssertEqual(first, second, file: file, line: line)
    }
    
}

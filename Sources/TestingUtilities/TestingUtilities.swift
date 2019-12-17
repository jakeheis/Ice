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
    
    public static func byVersion(swift5_1AndAbove: Assertion? = nil, swift5AndAbove: Assertion? = nil, swift4_2AndAbove: Assertion? = nil, swift4_1AndAbove: Assertion? = nil, swift4_0AndAbove: Assertion) {
        differentiate.byVersion(swift5_1AndAbove: swift5_1AndAbove, swift5AndAbove: swift5AndAbove, swift4_2AndAbove: swift4_2AndAbove, swift4_1AndAbove: swift4_1AndAbove, swift4_0AndAbove: swift4_0AndAbove)
    }
    
    private static let differentiate = Differentiate()
    
    private init() {
        let platform: String
        #if os(macOS)
        platform = "macOS"
        #else
        platform = "Linux"
        #endif
        
        let version: String
        #if swift(>=5.0.50)
        version = "5.1 (and above)"
        #elseif swift(>=5.0)
        version = "5.0"
        #elseif swift(>=4.1.50)
        version = "4.2"
        #elseif swift(>=4.1)
        version = "4.1"
        #else
        version = "4.0"
        #endif
        
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
    
    private func byVersion(swift5_1AndAbove: Assertion?, swift5AndAbove: Assertion?, swift4_2AndAbove: Assertion?, swift4_1AndAbove: Assertion?, swift4_0AndAbove: Assertion) {
        #if swift(>=5.0.50)
        if let swift5_1AndAbove = swift5_1AndAbove {
            swift5_1AndAbove()
        } else if let swift5AndAbove = swift5AndAbove {
            swift5AndAbove()
        } else if let swift4_2AndAbove = swift4_2AndAbove {
            swift4_2AndAbove()
        } else if let swift4_1AndAbove = swift4_1AndAbove {
            swift4_1AndAbove()
        } else {
            swift4_0AndAbove()
        }
        #elseif swift(>=5.0)
        if let swift5AndAbove = swift5AndAbove {
            swift5AndAbove()
        } else if let swift4_2AndAbove = swift4_2AndAbove {
            swift4_2AndAbove()
        } else if let swift4_1AndAbove = swift4_1AndAbove {
            swift4_1AndAbove()
        } else {
            swift4_0AndAbove()
        }
        #elseif swift(>=4.1.50)
        if let swift4_2AndAbove = swift4_2AndAbove {
            swift4_2AndAbove()
        } else if let swift4_1AndAbove = swift4_1AndAbove {
            swift4_1AndAbove()
        } else {
            swift4_0AndAbove()
        }
        #elseif swift(>=4.1)
        if let swift4_1AndAbove = swift4_1AndAbove {
        swift4_1AndAbove()
        } else {
        swift4_0AndAbove()
        }
        #else
        swift4_0AndAbove()
        #endif
    }
    
}

public func IceAssertEqual<T: Equatable>(_ first: T?, _ second: T?, file: StaticString = #file, line: UInt = #line) {
    if let firstValue = first, let secondValue = second {
        XCTAssertEqual(firstValue, secondValue, file: file, line: line)
    } else {
        XCTAssertEqual(first, second, file: file, line: line)
    }
    
}

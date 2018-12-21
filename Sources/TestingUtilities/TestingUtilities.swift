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
    
    public static func byVersion(swift4_2AndAbove: Assertion? = nil, swift4_1AndAbove: Assertion? = nil, swift4_0AndAbove: Assertion) {
        differentiate.byVersion(swift4_2AndAbove: swift4_2AndAbove, swift4_1AndAbove: swift4_1AndAbove, swift4_0AndAbove: swift4_0AndAbove)
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
        #if swift(>=4.1.50)
        version = "4.2 (and above)"
        #elseif swift(>=4.1)
        version = "4.1"
        #else
        version = "4.0"
        #endif
        
        print("Running tests on \(platform), Swift version \(version)")
    }
    
    private func byPlatform(mac: Assertion, linux: Assertion) {
        #if os(macOS)
        mac()
        #else
        linux()
        #endif
    }
    
    private func byVersion(swift4_2AndAbove: Assertion?, swift4_1AndAbove: Assertion?, swift4_0AndAbove: Assertion) {
        // TODO: swift(>=4.2) doesn't work here for some reason, so using 4.1.4 even though that version doesn't exist
        #if swift(>=4.1.50)
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

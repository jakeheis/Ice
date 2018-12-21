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

enum SupportedPlatforms {
    case mac
    case linux
}

enum SupportedSwiftVersions {
    case v4_0
    case v4_1
    case v4_2
}

public typealias Assertion = () -> ()

public func differentiatedAssert(swift4_2AndAbove: Assertion? = nil, swift4_1AndAbove: Assertion? = nil, swift4_0AndAbove: Assertion) {
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

public func differentiatedAssertEquality<T: Equatable>(_ value: T, swift4_2AndAbove: T? = nil, swift4_1AndAbove: T? = nil, swift4_0AndAbove: T, file: StaticString = #file, line: UInt = #line) {
    differentiatedAssert(swift4_2AndAbove: {
        XCTAssertEqual(value, swift4_2AndAbove ?? swift4_1AndAbove ?? swift4_0AndAbove, file: file, line: line)
    }, swift4_1AndAbove: {
        XCTAssertEqual(value, swift4_1AndAbove ?? swift4_0AndAbove, file: file, line: line)
    }, swift4_0AndAbove: {
        XCTAssertEqual(value, swift4_0AndAbove, file: file, line: line)
    })
}

public func differentiatedAssertEquality<T: Equatable>(_ value: T?, swift4_2AndAbove: T? = nil, swift4_1AndAbove: T? = nil, swift4_0AndAbove: T, file: StaticString = #file, line: UInt = #line) {
    if let value = value {
        differentiatedAssertEquality(value, swift4_2AndAbove: swift4_2AndAbove, swift4_1AndAbove: swift4_1AndAbove, swift4_0AndAbove: swift4_0AndAbove, file: file, line: line)
        return
    }
    differentiatedAssert(swift4_2AndAbove: {
        XCTAssertEqual(value, swift4_2AndAbove ?? swift4_1AndAbove ?? swift4_0AndAbove, file: file, line: line)
    }, swift4_1AndAbove: {
        XCTAssertEqual(value, swift4_1AndAbove ?? swift4_0AndAbove, file: file, line: line)
    }, swift4_0AndAbove: {
        XCTAssertEqual(value, swift4_0AndAbove, file: file, line: line)
    })
}

struct Expected {
    
    let platform: SupportedPlatforms
    let version: SupportedSwiftVersions
    let text: String
    
//    init(platform: SupportedPlatforms, version: SupportedSwiftVersions, text: String)
    
}

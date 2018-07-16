//
//  Runner.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation

class IceConfig: SandboxConfig {
    
    enum Templates: String {
        case empty
        case lib
        case exec
    }
    
    static let executable = "ice"
    
    static func configure(process: Process) {
        var env = ProcessInfo.processInfo.environment
        env["ICE_GLOBAL_ROOT"] = "global"
        process.environment = env
    }
    
}

typealias IceBox = Sandbox<IceConfig>

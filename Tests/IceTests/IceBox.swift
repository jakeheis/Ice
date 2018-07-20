//
//  Icebox.swift
//  IceTests
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation
import Icebox

class IceConfig: IceboxConfig {
    
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

typealias IceBox = Icebox<IceConfig>

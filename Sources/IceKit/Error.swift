//
//  Error.swift
//  Ice
//
//  Created by Jake Heiser on 8/30/17.
//

import Rainbow
import SwiftCLI

public struct IceError: SwiftCLI.ProcessError {
    public let message: String?
    public let exitStatus: Int32
    public init(message: String? = nil, exitStatus: Int32 = 1) {
        if let message = message {
            self.message = "\nError: ".red.bold + message + "\n"
        } else {
            self.message = nil
        }
        self.exitStatus = exitStatus
    }
}

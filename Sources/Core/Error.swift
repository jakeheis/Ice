//
//  Error.swift
//  Ice
//
//  Created by Jake Heiser on 8/30/17.
//

import SwiftCLI
import Rainbow
import Files

public struct IceError: SwiftCLI.ProcessError {
    public let message: String?
    public let exitStatus: Int32
    public init(message: String?, exitStatus: Int32) {
        if let message = message {
            self.message = "\nError: ".red + message + "\n"
        } else {
            self.message = nil
        }
        self.exitStatus = exitStatus
    }
}

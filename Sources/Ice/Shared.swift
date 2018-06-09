//
//  Shared.swift
//  CLI
//
//  Created by Jake Heiser on 4/19/18.
//

import Foundation
import IceKit
import SwiftCLI

struct InitializerOptions {
    static let library = Flag("-l", "--lib", "--library")
    static let executable = Flag("-e", "--exec", "--executable")
    static let typeGroup =  OptionGroup(options: [library, executable], restriction: .atMostOne)
}

extension Command {
    var verboseOut: WriteStream {
        return verbose.value ? WriteStream.stdout : WriteStream.null
    }
}

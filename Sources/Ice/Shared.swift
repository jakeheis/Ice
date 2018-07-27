//
//  Shared.swift
//  CLI
//
//  Created by Jake Heiser on 4/19/18.
//

import IceKit
import SwiftCLI

struct GlobalOptions {
    static let verbose = Flag("-v", "--verbose")
    
    private init() {}
}

struct InitializerOptions {
    static let library = Flag("-l", "--lib", description: "Create a new library project; default")
    static let executable = Flag("-e", "--exec", description: "Create a new executable project")
    static let typeGroup =  OptionGroup(options: [library, executable], restriction: .atMostOne)
    
    private init() {}
}

extension Command {
    
    var verbose: Flag {
        return GlobalOptions.verbose
    }
    
    var verboseOut: WriteStream {
        return verbose.value ? WriteStream.stdout : WriteStream.null
    }
    
}

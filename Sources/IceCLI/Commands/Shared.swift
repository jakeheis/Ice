//
//  Shared.swift
//  CLI
//
//  Created by Jake Heiser on 4/19/18.
//

import IceKit
import PathKit
import SwiftCLI

class IceObject {
    
    let ice: Ice
    
    var registry: Registry {
        return ice.registry
    }
    
    var config: Config {
        return ice.config(for: Path.current)
    }
    
    init(ice: Ice) {
        self.ice = ice
    }
    
    func loadPackage() throws -> Package {
        return try Package.load(config: config)
    }
    
}

struct GlobalOptions {
    static let verbose = Flag("-v", "--verbose", description: "Increase verbosity of informational output")
    
    private init() {}
}

extension Command {
    
    var verbose: Flag {
        return GlobalOptions.verbose
    }
    
    var verboseOut: WritableStream {
        return verbose.value ? WriteStream.stdout : WriteStream.null
    }
    
}

class CreateProjectCommand: IceObject {
    
    let library = Flag("-l", "--lib", description: "Create a new library project (default)")
    let executable = Flag("-e", "--exec", description: "Create a new executable project")
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne(library, executable)]
    }
    
    func createProject() throws {
        var type: SPM.InitType?
        if library.value {
            type = .library
        } else if executable.value {
            type = .executable
        }
        try SPM().initPackage(type: type)
        
        // Reformat
        var package = try loadPackage()
        package.dirty = true
        try package.sync()
    }
    
}

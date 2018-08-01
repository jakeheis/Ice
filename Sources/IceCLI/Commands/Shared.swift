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
    let config: Config
    
    var registry: Registry {
        return ice.registry
    }
    
    init(ice: Ice) {
        self.ice = ice
        self.config = ice.config(for: Path.current)
    }
    
}

struct GlobalOptions {
    static let verbose = Flag("-v", "--verbose")
    
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

class CreateProjectCommand {
    
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
        var package = try Package.load()
        package.dirty = true
        try package.sync()
    }
    
}

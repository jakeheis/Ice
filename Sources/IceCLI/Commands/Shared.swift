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
    
    var config: ConfigManager {
        return ice.config(for: .current)
    }
    
    init(ice: Ice) {
        self.ice = ice
    }
    
    func loadPackage() throws -> Package {
        return try Package.load(directory: .current, config: config.resolved)
    }
    
}

class CreateProjectCommand: IceObject {
    
    @Flag("-l", "--lib", description: "Create a new library project (default)")
    var library: Bool
    
    @Flag("-e", "--exec", description: "Create a new executable project")
    var executable: Bool
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne($library, $executable)]
    }
    
    func createProject() throws {
        var type: SPM.InitType?
        if library {
            type = .library
        } else if executable {
            type = .executable
        }
        try SPM().initPackage(type: type)
        
        // Reformat
        var package = try loadPackage()
        package.dirty = true
        try package.sync()
    }
    
}

class ForwardFlagsCommand: IceObject {
    static let keys = ["--Xcc", "--Xcxx", "--Xlinker", "--Xswiftc"]
    
    @VariadicKey(keys[0], description: "Pass flag through to all C compiler invocations")
    var cCompilerOptions: [String]
    
    @VariadicKey(keys[1], description: "Pass flag through to all C++ compiler invocations")
    var cxxCompilerOptions: [String]
    
    @VariadicKey(keys[2], description: "Pass flag through to all linker invocations")
    var linkerOptions: [String]
    
    @VariadicKey(keys[3], description: "Pass flag through to all Swift compiler invocations")
    var swiftCompilerOptions: [String]
    
    var forwardArguments: [String] {
        var args: [String] = []
        
        args += cCompilerOptions.flatMap { [String(Self.keys[0].dropFirst()), $0]  }
        args += cxxCompilerOptions.flatMap { [String(Self.keys[1].dropFirst()), $0]  }
        args += linkerOptions.flatMap { [String(Self.keys[2].dropFirst()), $0]  }
        args += swiftCompilerOptions.flatMap { [String(Self.keys[3].dropFirst()), $0]  }
        
        return args
    }
}

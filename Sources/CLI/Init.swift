//
//  Init.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI
import Core
import Rainbow

/*
 
 ice new Vapor
 
 ice init
 ice init --lib
 ice init --exec

 ice xc
 
 ice add jakeheis/SwiftCLI
 ice add jakeheis/SwiftCLI 3.0
 ice add -T jakeheis/SwiftCLI 3.0
 ice add --test jakeheis/SwiftCLI 3.0
 
 ice upgrade SwiftCLI
 ice upgrade SwiftCLI 4.0
 
 ice remove SwiftCLI
 ice remove jakeheis/SwiftCLI
 
 ice module Core
 ice module Commands --depends-on Core
 ice module Commands -d Core
 
 ice depend Commands --on Core
 ice depend Commands -o SwiftCLI
 ice depend Core --on Files
 
 ice clean
 
 ice build --clean
 ice build -c
 ice build --watch

 ice test
 
 ice run
 ice run --watch
 
 ice search SwiftCLI

 ice describe SwiftCLI
 ice describe jakeheis/SwiftCLI
 
 ice add -G jakeheis/Flock
 ice add --global jakeheis/Flock 3.0
 
 ice upgrade -G Flock
 
 ice remove -G Flock
 
*/

class InitCommand: Command {
    
    let name = "init"
    let shortDescription = "Initializes a new package in the current directory"
    
    let library = InitializerOptions.library
    let executable = InitializerOptions.executable
    let optionGroups = [InitializerOptions.typeGroup]
    
    func execute() throws {
        var type: SPM.InitType?
        if library.value {
            type = .library
        } else if executable.value {
            type = .executable
        }
        try SPM().initPackage(type: type)
        
        stdout <<< ""
        stdout <<< "Run: ".blue.bold + "ice build"
        stdout <<< ""
    }
    
}

//
//  Build.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import SwiftCLI

class BuildCommand: Command {
    
    let name = "build"
    let shortDescription = "Builds the current project"
    
    @Key("-t", "--target", description: "The individual target to build; cannot be used with --product")
    var target: String
    
    @Key("-p", "--product", description: "The individual product to build; cannot be used with --target")
    var product: String
    
    @Flag("-c", "--clean", description: "Clean the build folder before building")
    var clean: Bool
    
    @Flag("-r", "--release", description: "Build with the release configuration")
    var release: Bool
    
    @Flag("-w", "--watch", description: "Watch the current folder and rebuild any time a file changes")
    var watch: Bool
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne($target, $product)]
    }
    
    func execute() throws {
        let spm = SPM()
        
        if clean {
            try spm.clean()
        }
        
        if watch {
            let watcher = try SourceWatcher() {
                do {
                    self.stdout <<< "[ice] rebuilding due to changes...".green
                    try self.build(spm: spm)
                } catch {}
            }
            try watcher.go()
        } else {
            try build(spm: spm)
        }
    }
    
    func build(spm: SPM) throws {
        let buildOption: SPM.BuildOption? = target.flatMap { .target($0) } ?? product.flatMap { .product($0) }
        try spm.build(release: release, buildOption: buildOption)
    }
    
}

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
    
    let target = Key<String>("-t", "--target", description: "The individual target to build; cannot be used with --product")
    let product = Key<String>("-p", "--product", description: "The individual product to build; cannot be used with --target")
    
    let clean = Flag("-c", "--clean", description: "Clean the build folder before building")
    let release = Flag("-r", "--release", description: "Build with the release configuration")
    let watch = Flag("-w", "--watch", description: "Watch the current folder and rebuild any time a file changes")
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne(target, product)]
    }
    
    func execute() throws {
        let spm = SPM()
        
        if clean.value {
            try spm.clean()
        }
        
        if watch.value {
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
        let buildOption: SPM.BuildOption? = target.value.flatMap { .target($0) } ?? product.value.flatMap { .product($0) }
        try spm.build(release: release.value, buildOption: buildOption)
    }
    
}

//
//  Run.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import Rainbow
import SwiftCLI

class RunCommand: Command {
    
    let name = "run"
    let shortDescription = "Runs the executable of the current package"
    
    @Param(completion: .none)
    var executable: String?
    
    @CollectedParam
    var args: [String]
    
    @Flag("-r", "--release", description: "Run the executable built with the release configuration")
    var release: Bool
    
    @Flag("-w", "--watch", description: "Watch the project directory for changes, restarting the executable when change detected")
    var watch: Bool
    
    var task: Task? = nil
    
    func execute() throws {
        let spm = SPM()
        
        if watch {
            let watcher = try SourceWatcher() {
                self.stdout <<< "[ice] restarting due to changes...".green
                self.task?.interrupt()
                self.task = try? spm.run(release: self.release, executable: self.spmRunArguments())
            }
            try watcher.go()
        } else {
            try spm.runWithoutReturning(release: release, executable: spmRunArguments())
        }
    }
    
    private func spmRunArguments() -> [String] {
        let name = executable.flatMap({ [$0] }) ?? []
        return name + args
    }
    
}

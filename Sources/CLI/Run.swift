//
//  Run.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import Core
import Rainbow
import SwiftCLI

class RunCommand: Command {
    
    let name = "run"
    let shortDescription = "Runs the executable of the current package"
    
    let executable = OptionalParameter()
    let args = OptionalCollectedParameter()
    
    let release = Flag("-r", "--release")
    let watch = Flag("-w", "--watch")
    
    var task: Task? = nil
    
    func execute() throws {
        let spm = SPM()

        if watch.value {
            let watcher = try SourceWatcher() {
                self.stdout <<< "[ice] restarting due to changes...".green
                self.task?.interrupt()
                self.task = try? spm.run(release: self.release.value, executable: self.spmRunArguments())
            }
            try watcher.go()
        } else {
            try spm.runWithoutReturning(release: release.value, executable: spmRunArguments())
        }
    }
    
    private func spmRunArguments() -> [String] {
        let name = executable.value.flatMap({ [$0] }) ?? []
        return name + args.value
    }
    
}

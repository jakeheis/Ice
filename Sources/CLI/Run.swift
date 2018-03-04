//
//  Run.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import Exec
import Rainbow
import Dispatch

class RunCommand: Command {
    
    let name = "run"
    let shortDescription = "Runs the executable of the current package"
    
    let executable = OptionalCollectedParameter()
    
    let release = Flag("-r", "--release")
    let watch = Flag("-w", "--watch")
    
    func execute() throws {
        let spm = SPM()
        
        if watch.value {
            let runQueue = DispatchQueue(label: "com.jakeheis.Ice.RunCommand")
            let watcher = try SourceWatcher() {
                print("[ice] restarting due to changes...".green)
                InterruptCatcher.interrupt()
                runQueue.async {
                    do {
                        try spm.run(release: self.release.value, executable: self.executable.value ?? [])
                    } catch {}
                }
            }
            try watcher.go()
        } else {
            try spm.run(release: release.value, executable: executable.value ?? [])
        }
    }
    
}

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
    
    let release = Flag("-r", "--release")
    let watch = Flag("-w", "--watch")
    
    func execute() throws {
        let spm = SPM()
        
        guard watch.value else {
            try spm.run(release: release.value)
            return
        }
        
        let runQueue = DispatchQueue(label: "com.jakeheis.Ice.RunCommand")
        
        let watcher = try Watcher(action: {
            print("[ice] restarting due to changes...".green)
            InterruptCatcher.interrupt()
            runQueue.async {
                do {
                    try spm.run(release: self.release.value)
                } catch {}
            }
        })
        watcher.go()
    }
    
}

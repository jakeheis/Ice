//
//  InterruptCatcher.swift
//  Exec
//
//  Created by Jake Heiser on 9/12/17.
//

import Foundation

public class InterruptCatcher {
    
    static var currentProcess: Process?
    
    static func start(process: Process) {
        currentProcess = process
        signal(SIGINT) { (val) in
            InterruptCatcher.interrupt()
            
            // After interrupting subprocess, interrupt this process
            signal(SIGINT, SIG_DFL)
            raise(SIGINT)
        }
    }
    
    public static func interrupt() {
        currentProcess?.interrupt()
    }
    
    static func end() {
        signal(SIGINT, SIG_DFL)
    }
    
    private init() {}
    
}


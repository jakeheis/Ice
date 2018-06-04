//
//  Git.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/29/17.
//

import Dispatch
import SwiftCLI

class Git {
    
    static func clone(url: String, to path: String, version: Version?, silent: Bool = false, timeout: Int? = nil) throws {
        var args = ["clone", "--depth", "1"]
        if let version = version {
            args += ["--branch", version.raw]
        }
        try runGit(args: args + [url, path], silent: silent, timeout: timeout)
    }
    
    static func pull(path: String, silent: Bool, timeout: Int? = nil) throws {
        try runGit(args: ["-C", path, "pull"], silent: silent, timeout: timeout)
    }
    
    static func getRemoteUrl(of path: String) throws -> String {
        return try captureGit("-C", path, "remote", "get-url", "origin").stdout
    }
    
    static func lsRemote(url: String) throws -> String {
        return try captureGit("ls-remote", "--tags", url).stdout
    }
    
    private static func runGit(args: [String], silent: Bool, timeout: Int? = nil) throws {
        let stdout: WriteStream = silent ? .null : .stdout
        let stderr: WriteStream = silent ? .null : .stderr
        let task = Task(executable: "git", arguments: args, stdout: stdout, stderr: stderr)
        
        let interruptItem = createInterruptItem(task: task, timeout: timeout)
        
        let exitStatus = task.runSync()
        
        interruptItem?.cancel()
        
        guard exitStatus == 0 else {
            throw IceError(message: "git cmd failed", exitStatus: exitStatus)
        }
    }
    
    private static func captureGit(_ args: String...) throws -> CaptureResult {
        return try capture("git", arguments: args)
    }
    
    private static func createInterruptItem(task: Task, timeout: Int?) -> DispatchWorkItem? {
        guard let timeout = timeout else {
            return nil
        }
        
        let item = DispatchWorkItem { [weak task] in
            task?.interrupt()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(timeout), execute: item)
        return item
    }
    
}

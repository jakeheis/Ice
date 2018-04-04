//
//  Git.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/29/17.
//

import Dispatch
import Exec
import SwiftCLI

class Git {
    
    static func clone(url: String, to path: String, version: Version?, silent: Bool = false, timeout: Int? = nil) throws {
        var args = ["clone", "--depth", "1"]
        if let version = version {
            args += ["--branch", version.raw]
        }
        try exec(args: args + [url, path], silent: silent, timeout: timeout)
    }
    
    static func pull(path: String, silent: Bool, timeout: Int? = nil) throws {
        try exec(args: ["-C", path, "pull"], silent: silent, timeout: timeout)
    }
    
    static func getRemoteUrl(of path: String) throws -> String {
        return try cap("-C", path, "remote", "get-url", "origin").stdout
    }
    
    static func lsRemote(url: String) throws -> String {
        return try cap("ls-remote", "--tags", url).stdout
    }
    
    private static func exec(args: [String], silent: Bool, timeout: Int? = nil) throws {
        let stdout: WriteStream = silent ? .null : .stdout
        let stderr: WriteStream = silent ? .null : .stderr
        let task = Task(executable: "git", args: args, stdout: stdout, stderr: stderr)
        
        let interruptItem = createInterruptItem(task: task, timeout: timeout)
        
        let exitStatus = task.runSync()
        
        interruptItem?.cancel()
        
        guard exitStatus == 0 else {
            throw IceError(message: "git cmd failed", exitStatus: exitStatus)
        }
    }
    
    private static func cap(_ args: String...) throws -> CaptureResult {
        return try capture("git", args)
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

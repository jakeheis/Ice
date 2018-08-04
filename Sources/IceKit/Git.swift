//
//  Git.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/29/17.
//

import Dispatch
import SwiftCLI

class Git {
    
    static func clone(url: String, to path: String, silent: Bool = false, timeout: Int? = nil) throws {
        try runGit(args: ["clone", "--depth", "1", url, path], silent: silent, timeout: timeout)
    }
    
    static func pull(path: String, silent: Bool, timeout: Int? = nil) throws {
        try runGit(args: ["-C", path, "pull"], silent: silent, timeout: timeout)
    }
    
    static func lsRemote(url: String) throws -> [Version] {
        var versions: [Version] = []
        let out = LineStream { (line) in
            guard let index = line.index(of: "\t") else {
                return
            }
            let name = String(line[line.index(index, offsetBy: "refs/tags/".count + 1)...])
            if let version = Version(name) {
                versions.append(version)
            }
        }
        let task = Task(executable: "git", arguments: ["ls-remote", "--tags", url], stdout: out, stderr: WriteStream.null)
        let exitStatus = task.runSync()
        guard exitStatus == 0 else {
            throw IceError(message: "couldn't retrieve versions at \(url)", exitStatus: exitStatus)
        }
        return versions
    }
    
    private static func runGit(args: [String], silent: Bool, timeout: Int? = nil) throws {
        let stdout: WritableStream = silent ? WriteStream.null : WriteStream.stdout
        let stderr: WritableStream = silent ? WriteStream.null : WriteStream.stderr
        let task = Task(executable: "git", arguments: args, stdout: stdout, stderr: stderr)
        
        let interruptItem = createInterruptItem(task: task, timeout: timeout)
        
        let exitStatus = task.runSync()
        
        interruptItem?.cancel()
        
        guard exitStatus == 0 else {
            throw IceError(message: "git cmd failed", exitStatus: exitStatus)
        }
    }
    
    private static func createInterruptItem(task: Task, timeout: Int?) -> DispatchWorkItem? {
        guard let timeout = timeout else {
            return nil
        }
        
        let item = DispatchWorkItem { [weak task] in
            task?.terminate()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(timeout), execute: item)
        return item
    }
    
}

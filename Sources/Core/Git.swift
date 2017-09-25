//
//  Git.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/29/17.
//

import Exec

class Git {
    
    static func clone(url: String, to path: String, version: Version?, silent: Bool = false, timeout: Int? = nil) throws {
        var args = ["clone", "--depth", "1"]
        if let version = version {
            args += ["--branch", version.raw]
        }
        let command = exec(arguments: args + [url, path], timeout: timeout)
        if silent {
            _ = try command.capture()
        } else {
            try command.execute()
        }
    }
    
    static func pull(path: String, silent: Bool, timeout: Int? = nil) throws {
        let command = exec(arguments: ["-C", path, "pull"], timeout: timeout)
        if silent {
            _ = try command.capture()
        } else {
            try command.execute()
        }
    }
    
    static func getRemoteUrl(of path: String) throws -> String {
        return try exec(arguments: ["-C", path, "remote", "get-url", "origin"]).capture().stdout
    }
    
    static func lsRemote(url: String) throws -> String {
        return try exec(arguments: ["ls-remote", "--tags", url]).capture().stdout
    }
    
    private static func exec(arguments: [String], timeout: Int? = nil) -> Exec {
        return Exec(command: "git", args: arguments, timeout: timeout)
    }
    
}

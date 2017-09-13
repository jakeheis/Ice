//
//  Git.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/29/17.
//

import Exec

class Git {
    
    static func clone(url: String, to path: String, version: Version?) throws {
        var args = ["clone", "--depth", "1"]
        if let version = version {
            args += ["--branch", version.raw]
        }
        try exec(arguments: args + [url, path]).execute()
    }
    
    static func getRemoteUrl(of path: String) throws -> String {
        return try exec(arguments: ["-C", path, "remote", "get-url", "origin"]).capture()
    }
    
    static func lsRemote(url: String) throws -> String {
        return try exec(arguments: ["ls-remote", "--tags", url]).capture()
    }
    
    private static func exec(arguments: [String]) -> Exec {
        return Exec(command: "git", args: arguments)
    }
    
}

//
//  Git.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/29/17.
//

import Foundation
import CLISpinner

class Git {
    
    static func clone(url: String, to path: String) throws {
        try exec(arguments: ["clone", url, path]).execute()
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

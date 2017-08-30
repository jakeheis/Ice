//
//  Git.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/29/17.
//

import Foundation

class Git {
    
    static func clone(url: String, to path: String) throws {
        try execute(["clone", url, path])
    }
    
    static func getRemoteUrl(of path: String) throws -> String {
        return try capture(["-C", path, "remote", "get-url", "origin"])
    }
    
    static func lsRemote(url: String) throws -> String {
        return try capture(["ls-remote", "--tags", url])
    }
    
    private static func execute(_ arguments: [String]) throws {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git"] + arguments
        process.launch()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw SwiftProcess.Error.processFailed
        }
    }
    
    private static func capture(_ arguments: [String]) throws -> String {
        let output = Pipe()
        
        let clone = Process()
        clone.launchPath = "/usr/bin/env"
        clone.arguments = ["git"] + arguments
        clone.standardOutput = output
        clone.launch()
        clone.waitUntilExit()
        
        guard clone.terminationStatus == 0 else {
            throw SwiftProcess.Error.processFailed
        }
        
        return String(data: output.fileHandleForReading.availableData, encoding: .utf8) ?? ""
    }
    
}

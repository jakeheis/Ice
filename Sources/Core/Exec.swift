//
//  Exec.swift
//  Core
//
//  Created by Jake Heiser on 8/31/17.
//

import Foundation

public class Exec {
    
    public struct Error: Swift.Error {
        let exitStatus: Int32
    }
    
    private let process: Process
    
    public init(command: String, args: [String], in currentDirectory: String? = nil) {
        self.process = Process()
        self.process.launchPath = "/usr/bin/env"
        self.process.arguments = [command] + args
        if let currentDirectory = currentDirectory {
            self.process.currentDirectoryPath = currentDirectory
        }
    }
    
    public func execute(transform: ((_ transformer: OutputTransformer) -> ())? = nil) throws {
        var transformer: OutputTransformer?
        if let transform = transform {
            let newTransformer = OutputTransformer()
            transform(newTransformer)
            newTransformer.attach(process)
            transformer = newTransformer
        }
        
        InterruptCatcher.start(process: process)
                
        print(transformer?.prefix ?? "", terminator: "")
        process.launch()
        process.waitUntilExit()
        print(transformer?.suffix ?? "", terminator: "")
        
        InterruptCatcher.end()
        
        guard process.terminationStatus == 0 else {
            throw Error(exitStatus: process.terminationStatus)
        }
    }
    
    public func captureData() throws -> Data {
        let output = Pipe()
        process.standardOutput = output
        
        InterruptCatcher.start(process: process)
        
        process.launch()
        process.waitUntilExit()
        
        InterruptCatcher.end()
        
        guard process.terminationStatus == 0 else {
            throw Error(exitStatus: process.terminationStatus)
        }
        
        return output.fileHandleForReading.availableData
    }
    
    public func capture() throws -> String {
        let data = try captureData()
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
}

private class InterruptCatcher {
    
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
    
    static func interrupt() {
        currentProcess?.interrupt()
    }
    
    static func end() {
        signal(SIGINT, SIG_DFL)
    }
    
}

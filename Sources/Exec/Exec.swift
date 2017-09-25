//
//  Exec.swift
//  Core
//
//  Created by Jake Heiser on 8/31/17.
//

import Foundation
import SwiftCLI
import Rainbow

public class Exec {
    
    public struct Error: ProcessError {
        public let exitStatus: Int32
        public let message: String? = nil
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
            newTransformer.start(with: process)
            transformer = newTransformer
        }
        
        InterruptCatcher.start(process: process)
        
        process.launch()
        process.waitUntilExit()
        transformer?.finish()

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

public func niceFatalError(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
    printError("\n\nFatal error:".bold.red + " \(message)\n")
    if _isDebugAssertConfiguration() {
        printError("\(file):\(line)\n")
    }
    exit(1)
}

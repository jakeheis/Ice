//
//  Exec.swift
//  Core
//
//  Created by Jake Heiser on 8/31/17.
//

import Foundation
import SwiftCLI
import Rainbow
import Dispatch
import Regex

public class Exec {
    
    public struct ExecuteError: ProcessError {
        public let exitStatus: Int32
        public let message: String? = nil
    }
    
    public struct CaptureError: ProcessError {
        public let stdout: Data
        public let stderr: Data
        public let exitStatus: Int32
        
        public var message: String? {
            if let fullError = String(data: stderr, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let error: String
                if let match = Regex("^[eE]rror: (.*)$").firstMatch(in: fullError), let rest = match.captures[0] {
                    error = rest
                } else {
                    error = fullError
                }
                return "\nError: ".red.bold + error + "\n"
            }
            return nil
        }
    }
    
    let process: Process
    let timeout: Int?
    
    public init(command: String, args: [String], in currentDirectory: String? = nil, timeout: Int? = nil) {
        self.process = Process()
        self.process.launchPath = "/usr/bin/env"
        self.process.arguments = [command] + args
        if let currentDirectory = currentDirectory {
            self.process.currentDirectoryPath = currentDirectory
        }
        self.timeout = timeout
    }
    
    public func execute(transform: ((_ transformer: OutputTransformer) -> ())? = nil) throws {
        var transformer: OutputTransformer?
        if let transform = transform {
            let newTransformer = OutputTransformer()
            transform(newTransformer)
            newTransformer.start(with: process)
            transformer = newTransformer
        }
        
        let item = createInterruptItem()
        InterruptCatcher.start(process: process)
        
        process.launch()
        process.waitUntilExit()
        transformer?.finish()

        InterruptCatcher.end()
        item?.cancel()

        guard process.terminationStatus == 0 else {
            throw ExecuteError(exitStatus: process.terminationStatus)
        }
    }
    
    public func captureData() throws -> (stdout: Data, stderr: Data) {
        let output = Pipe()
        process.standardOutput = output
        
        let err = Pipe()
        process.standardError = err
        
        let item = createInterruptItem()
        InterruptCatcher.start(process: process)
        
        process.launch()
        process.waitUntilExit()
        
        InterruptCatcher.end()
        item?.cancel()
        
        let stdout = output.fileHandleForReading.readDataToEndOfFile()
        let stderr = err.fileHandleForReading.readDataToEndOfFile()
        
        guard process.terminationStatus == 0 else {
            throw CaptureError(
                stdout: stdout,
                stderr: stderr,
                exitStatus: process.terminationStatus
            )
        }
        
        return (stdout, stderr)
    }
    
    public func capture() throws -> (stdout: String, stderr: String) {
        let (stdout, stderr) = try captureData()
        return (String(data: stdout, encoding: .utf8) ?? "", String(data: stderr, encoding: .utf8) ?? "")
    }
    
    private func createInterruptItem() -> DispatchWorkItem? {
        if let timeout = timeout {
            let item = DispatchWorkItem(block: { [weak self] in
                self?.process.interrupt()
            })
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(timeout), execute: item)
            return item
        } else {
            return nil
        }
    }
    
}

public func niceFatalError(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
    printError("\n\nFatal error:".bold.red + " \(message)\n")
    if _isDebugAssertConfiguration() {
        printError("\(file):\(line)\n")
    }
    exit(1)
}

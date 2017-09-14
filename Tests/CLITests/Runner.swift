//
//  Runner.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation

struct ExecutionResult {
    let exitStatus: Int32
    let stdout: String
    let stderr: String
}

func sandboxedFileContents(_ path: String) -> String? {
    let sandboxedPath = Runner.sandboxedDirectory + "/" + path
    guard let data = FileManager.default.contents(atPath: sandboxedPath) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}

func writeToSandbox(path: String, contents: String) {
    let sandboxedPath = Runner.sandboxedDirectory + "/" + path
    try! contents.write(toFile: sandboxedPath, atomically: true, encoding: .utf8)
}

class Sandbox {
    static let empty: Sandbox = Sandbox(name: "Empty")
    static let lib: Sandbox = Sandbox(name: "Lib")
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

class Runner {
    
    static let sandboxedDirectory = ".sandbox"
    
    @discardableResult
    static func execute(args: [String], sandbox: Sandbox = .empty, sandboxSetup: (() -> ())? = nil, clean: Bool = true) -> ExecutionResult {
        if clean {
            if FileManager.default.fileExists(atPath: sandboxedDirectory) {
                try! FileManager.default.removeItem(atPath: sandboxedDirectory)
            }
            
            try! FileManager.default.copyItem(atPath: "Tests/Sandboxes/\(sandbox.name)", toPath: sandboxedDirectory)
        }
        
        sandboxSetup?()
        
        let process = Process()
        process.launchPath = FileManager.default.currentDirectoryPath + "/.build/debug/ice"
        process.currentDirectoryPath = sandboxedDirectory
        process.arguments = args
        
        var env = ProcessInfo.processInfo.environment
        env["ICE_GLOBAL_ROOT"] = "global"
        process.environment = env
        
        let output = Pipe()
        let error = Pipe()
        
        process.standardOutput = output
        process.standardError = error
        
        process.launch()
        process.waitUntilExit()
                
        return ExecutionResult(
            exitStatus: process.terminationStatus,
            stdout: String(data: output.fileHandleForReading.availableData, encoding: .utf8) ?? "",
            stderr: String(data: error.fileHandleForReading.availableData, encoding: .utf8) ?? ""
        )
    }
    
}

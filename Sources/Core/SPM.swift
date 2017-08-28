//
//  SPM.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation

public class SPM {

    let path: String

    public init(path: String = ".") {
        self.path = path
    }
    
    public enum InitType: String {
        case executable
        case library
    }
    
    public func initPackage(type: InitType?) throws {
        var args = ["package", "init"]
        if let type = type {
            args += ["--type", type.rawValue]
        }
        try execute(arguments: args)
    }

    public func build(release: Bool = false) throws {
        var args = ["build"]
        if release {
            args += ["-c", "release"]
        }
        try execute(arguments: args)
    }
    
    public func clean() throws {
        try execute(arguments: ["package", "clean"])
    }

    public func test() throws {
        try execute(arguments: ["test"])
    }

    public func generateXcodeProject() throws {
        try execute(arguments: ["package", "generate-xcodeproj"])
    }
    
    func showBinPath(release: Bool = false) throws -> String {
        var args = ["build", "--show-bin-path"]
        if release {
            args += ["-c", "release"]
        }
        let data = try capture(arguments: args)
        guard let retVal = String(data: data, encoding: .utf8) else {
            throw SwiftProcess.Error.processFailed
        }
        return retVal.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func dumpPackage() throws -> Data {
        let output = try capture(arguments: ["package", "dump-package"])
        guard let jsonStart = output.index(of: UInt8("{".cString(using: .ascii)![0])) else {
            throw SwiftProcess.Error.processFailed
        }
        return output.subdata(in: jsonStart..<output.endIndex)
    }

    private func execute(arguments: [String]) throws {
        try SwiftProcess.execute(arguments: arguments, in: path)
    }
    
    private func capture(arguments: [String]) throws -> Data {
        return try SwiftProcess.capture(arguments: arguments, in: path)
    }
    
}

public class SwiftProcess {
    
    public enum Error: Swift.Error {
        case processFailed
    }
    
    private static var buildProcess: Process?
    
    static func execute(arguments: [String], in dir: String) throws {
        _ = try run(arguments: arguments, capture: false, in: dir)
    }
    
    static func capture(arguments: [String], in dir: String) throws -> Data {
        let value = try run(arguments: arguments, capture: true, in: dir)
        return value!
    }
    
    private static func run(arguments: [String], capture: Bool, in dir: String) throws -> Data? {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["swift"] + arguments
        task.currentDirectoryPath = dir
        if capture {
            task.standardOutput = Pipe()
            task.standardError = Pipe()
        }
        task.launch()
        
        buildProcess = task
        
        signal(SIGINT) { (val) in
            SwiftProcess.interruptBuild()
            
            // After interrupting SPM, interrupt Bark
            signal(SIGINT, SIG_DFL)
            raise(SIGINT)
        }
        
        task.waitUntilExit()
        
        signal(SIGINT, SIG_DFL)
        
        guard task.terminationStatus == 0 else {
            print(arguments)
            throw Error.processFailed
        }
        
        if capture {
            let pipe = task.standardOutput as! Pipe
            return pipe.fileHandleForReading.readDataToEndOfFile()
        }
        
        return nil
    }
    
    private static func interruptBuild() {
        buildProcess?.interrupt()
    }
    
}

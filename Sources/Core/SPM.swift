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
        try SwiftProcess.execute(arguments: args)
    }

    public func build() throws {
        try SwiftProcess.execute(arguments: ["build"])
    }
    
    public func clean() throws {
        try SwiftProcess.execute(arguments: ["package", "clean"])
    }

    public func test() throws {
        try SwiftProcess.execute(arguments: ["test"])
    }

    public func generateXcodeProject() throws {
        try SwiftProcess.execute(arguments: ["package", "generate-xcodeproj"])
    }

    public func dumpPackage() throws -> Data {
        let output = try SwiftProcess.capture(arguments: ["package", "dump-package"])
        guard let jsonStart = output.index(of: UInt8("{".cString(using: .ascii)![0])) else {
            throw SwiftProcess.Error.processFailed
        }
        return output.subdata(in: jsonStart..<output.endIndex)
    }

}

public class SwiftProcess {
    
    public enum Error: Swift.Error {
        case processFailed
    }
    
    private static var buildProcess: Process?
    
    static func execute(arguments: [String]) throws {
        _ = try run(arguments: arguments, capture: false)
    }
    
    static func capture(arguments: [String]) throws -> Data {
        let value = try run(arguments: arguments, capture: true)
        return value!
    }
    
    private static func run(arguments: [String], capture: Bool) throws -> Data? {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["swift"] + arguments
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

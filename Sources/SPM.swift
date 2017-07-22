//
//  SPM.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation

class SPM {
    
    enum Error: Swift.Error {
        case processFailed
    }
    
    private static var buildProcess: Process?
    
    //    static func dump() throws -> [String: Any] {
    //        var output = try capture(arguments: ["package", "dump-package"])
    //        guard let jsonStart = output.index(of: UInt8("{".cString(using: .ascii)![0])) else {
    //            throw Error.processFailed
    //        }
    //        output = output.subdata(in: jsonStart..<output.endIndex)
    //        guard let json = try? JSONSerialization.jsonObject(with: output, options: []),
    //            let dict = json as? [String: Any] else {
    //                throw Error.processFailed
    //        }
    //
    //        return dict
    //    }
    
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
            SPM.interruptBuild()
            
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

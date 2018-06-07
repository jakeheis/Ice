//
//  SPM.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import FileKit
import Foundation
import Regex
import SwiftCLI

public class SPM {
    
    public let directory: Path
    
    public init(directory: Path = ".") {
        self.directory = directory
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
        try runSwift(args: args, transformer: .initialize)
    }
    
    // MARK: - Building
    
    public func build(release: Bool, includeTests: Bool = false, target: String? = nil) throws {
        // Resolve verbosely first because for some reason, SPM does not flush pipe
        // when printing package resolution info
        try resolve()
        
        var args = ["build"]
        if release {
            args += ["-c", "release"]
        }
        if includeTests {
            args.append("--build-tests")
        }
        if let target = target {
            args += ["--target", target]
        }
        try runSwift(args: args, transformer: .build)
    }
    
    public func run(release: Bool, executable: [String]) throws -> Task {
        let arguments = try formArgumentsForRun(release: release, executable: executable)
        let task = Task(executable: "swift", arguments: arguments, directory: directory.rawValue)
        task.runAsync()
        return task
    }
    
    public func runWithoutReturning(release: Bool, executable: [String]) throws -> Never {
        let arguments = try formArgumentsForRun(release: release, executable: executable)
        try Task.execvp("swift", arguments: arguments, directory: directory.rawValue)
    }
    
    public func test(filter: String?) throws {
        try build(release: false, includeTests: true)
        
        var args = ["test"]
        if let filter = filter {
            args += ["--filter", filter]
        }
        try runSwift(args: args, transformer: .test)
    }
    
    public func resolve() throws {
        try runSwift(args: ["package", "-v", "resolve"], transformer: .resolve)
    }
    
    // MARK: -
    
    public func clean() throws {
        try runSwift(args: ["package", "clean"])
    }
    
    public func reset() throws {
        try runSwift(args: ["package", "reset"])
    }
    
    public func update() throws {
        try runSwift(args: ["package", "update"], transformer: .resolve)
    }

    public func generateXcodeProject() throws {
        try runSwift(args: ["package", "generate-xcodeproj"], transformer: .xc)
    }
    
    public func showBinPath(release: Bool = false) throws -> String {
        var args = ["build", "--show-bin-path"]
        if release {
            args += ["-c", "release"]
        }
        let path = try captureSwift(args: args).stdout
        guard !path.isEmpty else {
            throw IceError(message: "couldn't retrieve executable path")
        }
        return path.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func dumpPackage() throws -> Data {
        let content = try captureSwift(args: ["package", "dump-package"]).stdout
        guard let jsonStart = content.index(of: "{"), let data = content[jsonStart...].data(using: .utf8) else {
            throw IceError(message: "couldn't parse package")
        }
        return data
    }

    // MARK: - Helpers
    
    private func runSwift(args: [String], transformer: TransformerPair? = nil) throws {
        let stdout: WritableStream = transformer?.createStdout() ?? WriteStream.stdout
        let stderr: WritableStream = transformer?.createStderr() ?? WriteStream.stderr
        
        let task = Task(executable: "swift", arguments: args, directory: directory.rawValue, stdout: stdout, stderr: stderr)
        let result = task.runSync()
        transformer?.wait()
        
        guard result == 0 else {
            throw IceError(exitStatus: result)
        }
    }
    
    private func captureSwift(args: [String]) throws -> CaptureResult {
        do {
            return try capture("swift", arguments: args, directory: directory.rawValue)
        } catch let error as CaptureError {
            let message: String?
            if error.captured.stderr.isEmpty {
                message = nil
            } else {
                if let match = Regex("[eE]rror: (.*)$").firstMatch(in: error.captured.stderr), let rest = match.captures[0] {
                    message = rest
                } else {
                    message = error.captured.stderr
                }
            }
            
            throw IceError(message: message, exitStatus: error.exitStatus)
        }
    }
    
    private func formArgumentsForRun(release: Bool, executable: [String]) throws -> [String] {
        try build(release: release)

        var args = ["run", "--skip-build"]
        if release {
            args += ["-c", "release"]
        }
        args += executable
        
        return args
    }
    
}

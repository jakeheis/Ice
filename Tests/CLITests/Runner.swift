//
//  Runner.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation
import XCTest
import Regex
import Rainbow

// MARK: -

struct ExecutionResult {
    let exitStatus: Int32
    let stdout: String
    let stderr: String
}

// MARK: -

func sandboxedFileContents(_ path: String) -> String? {
    let sandboxedPath = Runner.sandboxedDirectory + "/" + path
    guard let data = FileManager.default.contents(atPath: sandboxedPath) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}

func sandboxedFileData(_ path: String) -> Data? {
    let sandboxedPath = Runner.sandboxedDirectory + "/" + path
    return FileManager.default.contents(atPath: sandboxedPath)
}

func writeToSandbox(path: String, contents: String) {
    let sandboxedPath = Runner.sandboxedDirectory + "/" + path
    try! contents.write(toFile: sandboxedPath, atomically: true, encoding: .utf8)
}

func sandboxFileExists(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: Runner.sandboxedDirectory + "/" + path)
}

func createSandboxDirectory(path: String) {
    try! FileManager.default.createDirectory(atPath: Runner.sandboxedDirectory + "/" + path, withIntermediateDirectories: true, attributes: nil)
}

func readSandboxLink(path: String) -> String? {
    return try? FileManager.default.destinationOfSymbolicLink(atPath: Runner.sandboxedDirectory + "/" + path)
}

func XCTAssertMatch(_ text: String?, _ regex: StaticString, file: StaticString = #file, line: UInt = #line) {
    let message = "`\(text ?? "nil")` should match \(regex)"
    guard let nonNilText = text else {
        XCTAssertNotNil(text, message, file: file, line: line)
        return
    }
    XCTAssertTrue(Regex(regex).matches(nonNilText), message, file: file, line: line)
}

// MARK: -


class OutputViewer {
    
    var lines: [String]
    
    init(_ str: String) {
        self.lines = str.components(separatedBy: "\n")
    }
    func equals(_ str: String, file: StaticString = #file, line: UInt = #line) {
        guard let first = removeFirst(file: file, line: line) else { return }
        XCTAssertEqual(first, str, file: file, line: line)
    }
    func matches(_ str: StaticString, file: StaticString = #file, line: UInt = #line) {
        guard let first = removeFirst(file: file, line: line) else { return }
        XCTAssertMatch(first, str, file: file, line: line)
    }
    func empty(file: StaticString = #file, line: UInt = #line) {
        equals("", file: file, line: line)
    }
    func done(file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lines, [], file: file, line: line)
    }
    func any(file: StaticString = #file, line: UInt = #line) {
        _ = removeFirst(file: file, line: line)
    }
    func removeFirst(file: StaticString, line: UInt) -> String? {
        if lines.isEmpty {
            XCTFail("No lines left", file: file, line: line)
            return nil
        }
        return lines.removeFirst()
    }
}

extension String {
    func assert(run: (_ v: OutputViewer) -> ()) {
        run(OutputViewer(self))
    }
}

// MARK: -

class Sandbox {
    static let empty: Sandbox = Sandbox(name: "Empty")
    static let lib: Sandbox = Sandbox(name: "Lib")
    static let exec: Sandbox = Sandbox(name: "Exec")
    static let fail: Sandbox = Sandbox(name: "Fail")
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

class Runner {
    
    private static var currentProcess: Process?
    
    static let sandboxedDirectory = FileManager.default.currentDirectoryPath + "/.sandbox"
    
    static func clean() {
        if FileManager.default.fileExists(atPath: sandboxedDirectory) {
            try! FileManager.default.removeItem(atPath: sandboxedDirectory)
        }
    }
    
    @discardableResult
    static func execute(args: [String], sandbox: Sandbox = .empty, dir: String? = nil, sandboxSetup: (() -> ())? = nil, clean: Bool = true) -> ExecutionResult {
        if clean {
            self.clean()
            
            try! FileManager.default.copyItem(atPath: "Tests/Sandboxes/\(sandbox.name)", toPath: sandboxedDirectory)
            try! FileManager.default.copyItem(atPath: "Tests/Fixtures/global", toPath: sandboxedDirectory + "/global")
        }
        
        sandboxSetup?()
        
        let processWorkingDirectory: String
        if let dir = dir {
            let url = URL(fileURLWithPath: sandboxedDirectory + "/" + dir)
            let resolved = url.standardizedFileURL.path
            guard resolved.hasPrefix(sandboxedDirectory) else {
                fatalError("Cannot execute in directory outside of sandbox")
            }
            processWorkingDirectory = resolved
        } else {
            processWorkingDirectory = sandboxedDirectory
        }
        
        
        let process = Process()
        process.launchPath = FileManager.default.currentDirectoryPath + "/.build/debug/ice"
        process.currentDirectoryPath = processWorkingDirectory
        process.arguments = args
        
        var env = ProcessInfo.processInfo.environment
        env["ICE_GLOBAL_ROOT"] = "global"
        process.environment = env
        
        let output = Pipe()
        let error = Pipe()
        
        process.standardOutput = output
        process.standardError = error
        
        currentProcess = process
        process.launch()
        process.waitUntilExit()
                
        return ExecutionResult(
            exitStatus: process.terminationStatus,
            stdout: String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "",
            stderr: String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        )
    }
    
    static func interrupt() {
        currentProcess?.interrupt()
    }
    
}

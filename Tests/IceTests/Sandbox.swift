//
//  Sandbox.swift
//  Beach
//
//  Created by Jake Heiser on 6/8/18.
//

import Dispatch
import Foundation
import PathKit
import XCTest

protocol SandboxConfig {
    associatedtype Templates: RawRepresentable where Templates.RawValue == String
    
    static var templateLocation: Path { get }
    static var executable: String { get }
    
    static func configure(process: Process)
}

extension SandboxConfig {
    static var templateLocation: Path { return Path.current + "Tests" + "Templates" }
    
    static func configure(process: Process) {}
}

struct RunnerResult {
    
    let exitStatus: Int32
    let stdoutData: Data
    let stderrData: Data
    
    var stdout: String? {
        return String(data: stdoutData, encoding: .utf8)
    }
    
    var stderr: String? {
        return String(data: stderrData, encoding: .utf8)
    }
    
    init(exitStatus: Int32, stdoutData: Data, stderrData: Data) {
        self.exitStatus = exitStatus
        self.stdoutData = stdoutData
        self.stderrData = stderrData
    }
    
    func assertStdout(_ test: (LineTester) -> ()) {
        let tester = LineTester(content: stdout ?? "")
        test(tester)
    }
    
    func assertStderr(_ test: (LineTester) -> ()) {
        let tester = LineTester(content: stderr ?? "")
        test(tester)
    }
    
}

class Sandbox<Config: SandboxConfig> {
    
    typealias ProcessConfiguration = (Process) -> ()
    
    private let boxPath: Path
    private var currentProcess: Process?
    
    init(template: Config.Templates?, file: StaticString = #file, function: StaticString = #function) {
        let fileComps = Path(file.description).components
        let target = fileComps.index(of: "Tests").flatMap { fileComps[$0 + 1] } ?? "UnknownTarget"
        let file = Path(file.description).lastComponentWithoutExtension
        
        let notAllowed = CharacterSet.alphanumerics.inverted
        let trimmedExec = Config.executable.trimmingCharacters(in: notAllowed).replacingOccurrences(of: "/", with: "_")
        let trimmedFunc = function.description.trimmingCharacters(in: notAllowed)
        
        self.boxPath = Path("/tmp") + "\(trimmedExec)_sandbox" + target + file + trimmedFunc
        
        print(" Icebox: \(boxPath)")
        
        do {
            if boxPath.exists {
                try boxPath.delete()
            }
            
            if let template = template, template.rawValue.lowercased() != "empty" {
                try boxPath.parent().mkpath()
                try (Config.templateLocation + template.rawValue).copy(boxPath)
            } else {
                try boxPath.mkpath()
            }
        } catch let error {
            print()
            print("Beach: failed to set up sandbox")
            print()
            print("Error:", error)
            print()
            exit(1)
        }
    }
    
    // Set up
    
    func createFile(path: Path, contents: String) {
        let adjustedPath = createPath(path)
        if !adjustedPath.parent().exists {
            try! adjustedPath.parent().mkpath()
        }
        try! createPath(path).write(contents)
    }
    
    func createDirectory(path: Path) {
        try! createPath(path).mkpath()
    }
    
    func removeItem(_ path: Path) {
        try! createPath(path).delete()
    }
    
    func fileContents(_ path: Path) -> String? {
        return try? createPath(path).read()
    }
    
    func fileContents(_ path: Path) -> Data? {
        return try? createPath(path).read()
    }
    
    func fileExists(_ path: Path) -> Bool {
        return createPath(path).exists
    }
    
    private func createPath(_ relative: Path) -> Path {
        let full = (boxPath + relative).absolute()
        guard full.string.hasPrefix(boxPath.string + "/") else {
            print()
            print("Beach: attempted to modify file outside of sandbox")
            print()
            exit(1)
        }
        return full
    }
    
    // Run
    
    @discardableResult
    func run(_ arguments: String..., configure: ProcessConfiguration? = nil, timeout: Int? = nil, file: StaticString = #file, line: UInt = #line) -> RunnerResult {
        return run(arguments: arguments, configure: configure, timeout: timeout, file: file, line: line)
    }
    
    @discardableResult
    func run(arguments: [String], configure: ProcessConfiguration? = nil, timeout: Int? = nil, file: StaticString = #file, line: UInt = #line) -> RunnerResult {
        let out = Pipe()
        let err = Pipe()
        
        let process = Process()
        process.launchPath = (Path.current + ".build" + "debug" + Config.executable).absolute().string
        process.arguments = arguments
        process.currentDirectoryPath = boxPath.string
        process.standardOutput = out
        process.standardError = err
        
        Config.configure(process: process)
        configure?(process)
        
        currentProcess = process
        process.launch()
        
        // Timeout
        
        var interruptItem: DispatchWorkItem? = nil
        if let timeout = timeout {
            let item = DispatchWorkItem {
                XCTFail("Exceeded timeout (\(timeout) seconds), killing process", file: file, line: line)
                process.terminate()
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(timeout), execute: item)
            interruptItem = item
        }
        
        let outCollector = DataCollector(handle: out.fileHandleForReading)
        let errCollector = DataCollector(handle: err.fileHandleForReading)
        
        // Finish
        
        let stdout = outCollector.read()
        let stderr = errCollector.read()
        process.waitUntilExit()
        interruptItem?.cancel()
        currentProcess = nil
        
        return RunnerResult(exitStatus: process.terminationStatus, stdoutData: stdout, stderrData: stderr)
    }
    
    func interrupt() {
        currentProcess?.interrupt()
    }
    
}

private class DataCollector {
    
    let source: DispatchSourceRead
    
    private var data = Data()
    private let finished = DispatchSemaphore(value: 0)
    
    init(handle: FileHandle) {
        let source = DispatchSource.makeReadSource(fileDescriptor: handle.fileDescriptor)
        self.source = source
        source.setEventHandler {
            let chunk = handle.availableData
            if chunk.isEmpty {
                source.cancel()
                self.finished.signal()
            } else {
                self.data += chunk
            }
        }
        source.resume()
    }
    
    func read() -> Data {
        finished.wait()
        return data
    }
    
}

class LineTester {
    
    var lines: [String]
    
    init(content: String) {
        self.lines = content.components(separatedBy: "\n")
    }
    
    func equals(_ str: String, file: StaticString = #file, line: UInt = #line) {
        guard let first = removeFirst(file: file, line: line) else { return }
        XCTAssertEqual(first, str, file: file, line: line)
    }
    
    func matches(_ str: StaticString, file: StaticString = #file, line: UInt = #line) {
        guard let first = removeFirst(file: file, line: line) else { return }
        let regex = try! NSRegularExpression(pattern: str.description, options: [])
        
        let match = regex.firstMatch(in: first, options: [], range: NSRange(location: 0, length: first.utf16.count))
        XCTAssertTrue(match != nil, "`\(first)` should match \(regex.pattern)", file: file, line: line)
    }
    
    func empty(file: StaticString = #file, line: UInt = #line) {
        equals("", file: file, line: line)
    }
    
    func any(file: StaticString = #file, line: UInt = #line) {
        _ = removeFirst(file: file, line: line)
    }
    
    func done(file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lines, [], file: file, line: line)
    }
    
    private func removeFirst(file: StaticString, line: UInt) -> String? {
        if lines.isEmpty {
            XCTFail("No lines left", file: file, line: line)
            return nil
        }
        return lines.removeFirst()
    }
    
}

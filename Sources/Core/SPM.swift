//
//  SPM.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import Files
import CLISpinner
import Rainbow
import Regex

class TestSuiteResponse: Response {
    
    static let caseRegex = Regex("^Test Case .* ([^ ]*)\\]' (started|passed|failed)")
    static let doneRegex = Regex("Executed .* tests")
    
    let stream: Stream
    var suiteName: String?
    
    var done = false
    var failures: [String] = []
    
    init(stream: Stream) {
        self.stream = stream
    }
    
    func go(captures: [String]) {
        suiteName = captures[0]
        stream.output(badge(text: "RUNS", color: .blue), terminator: "")
    }
    
    func contine(on line: String) -> Bool {
        guard !done else {
            return false
        }
        done = TestSuiteResponse.doneRegex.matches(line)
        if let match = TestSuiteResponse.caseRegex.firstMatch(in: line) {
            if match.captures[1] == "failed" {
                if failures.isEmpty {
                    stream.output("\r" + badge(text: "FAIL", color: .red))
                    stream.output("")
                }
                failures.append(match.captures[0]!)
                print(" ● \(match.captures[0]!)".red.bold)
            }
        }
        return true
    }
    
    func stop() {
        if failures.isEmpty {
            stream.output("\r" + badge(text: "PASS", color: .green))
        } else {
            stream.output("")
        }
    }
    
    func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + suiteName!.bold
    }
    
}

class TestEndResponse: Response {
    
//    static let countRegex = Regex("Executed ([0-9]+) tests, with ([0-9]*) failure")
    static let countRegex = Regex("Executed ([0-9]+) tests, with ([0-9]*) failures? .* \\(([\\.0-9]+)\\) seconds$")

    let stream: Stream = .err
    var nextLine = true
    
    func go(captures: [String]) {
        stream.output("")
    }
    
    func contine(on line: String) -> Bool {
        guard nextLine else {
            return false
        }
        nextLine = false
        
        if let countMatch = TestEndResponse.countRegex.firstMatch(in: line) {
            if let totalStr = countMatch.captures[0], let totalCount = Int(totalStr),
                let failedStr = countMatch.captures[1], let failedCount = Int(failedStr) {
                
                var parts: [String] = []
                if failedCount > 0 {
                    parts.append("\(failedCount) failed".bold.red)
                }
                if failedCount < totalCount {
                    parts.append("\(totalCount - failedCount) passed".bold.green)
                }
                parts.append("\(totalCount) total")
                
                let output = "Tests:\t".bold.white + parts.joined(separator: ", ")
                stream.output(output)
            }
            if let time = countMatch.captures[2] {
                stream.output("Time:\t".bold.white + time + "s")
            }
        }
        
        return true
    }
    
    func stop() {}
    
}

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
        try exec(arguments: args).execute(transform: { (t) in
            t.first("\n")
            t.replace("(Creating .* package): (.*)") { $0[0] + ": " + $0[1].blue + "\n" }
            t.replace("Creating ([^:]+)$") { "    create ".blue + $0[0] }
            t.last("\n")
        })
    }

    public func build(release: Bool = false) throws {
        var args = ["build"]
        if release {
            args += ["-c", "release"]
        }
        try exec(arguments: args).execute(transform: { (t) in
            t.spin("Compile Swift Module '(.*)'", { "Compiling " + $0[0] }, { $0.succeed(text: "Compiled " + $1[0]) })
        })
    }
    
    public func clean() throws {
        try exec(arguments: ["package", "clean"]).execute()
    }

    public func test() throws {
        do {
            try exec(arguments: ["test"]).execute(transform: { (t) in
                t.spin("Compile Swift Module '(.*)'", { "Compiling " + $0[0] }, { $0.succeed(text: "Compiled " + $1[0]) })
                t.ignore("^Test Suite 'All tests' started", on: .err)
                t.replace("^Test Suite '(.*)\\.xctest' started", on: .err, { "\n\($0[0]):\n".dim })
                t.respond(on: .err, with: ResponseGenerator(matcher: "^Test Suite 'All tests' (passed|failed)", generate: {
                    return TestEndResponse()
                }))
                t.respond(on: .err, with: ResponseGenerator(matcher: "^Test Suite '(.*)'", generate: {
                    return TestSuiteResponse(stream: .err)
                }))
                t.ignore(".*", on: .out)
                t.last("\n")
            })
        } catch let error as Exec.Error {
            throw IceError(exitStatus: error.exitStatus)
        }
    }

    public func generateXcodeProject() throws {
        try exec(arguments: ["package", "generate-xcodeproj"]).execute()
    }
    
    func showBinPath(release: Bool = false) throws -> String {
        var args = ["build", "--show-bin-path"]
        if release {
            args += ["-c", "release"]
        }
        let path = try exec(arguments: args).capture()
        guard !path.isEmpty else {
            throw IceError(message: "couldn't retrieve executable path")
        }
        return path.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func dumpPackage() throws -> Data {
        let data = try exec(arguments: ["package", "dump-package"]).captureData()
        guard let jsonStart = data.index(of: UInt8("{".cString(using: .ascii)![0])) else {
            throw IceError(message: "couldn't parse package")
        }
        return data[jsonStart...]
    }

    private func exec(arguments: [String]) -> Exec {
        return Exec(command: "swift", args: arguments, in: path)
    }
    
}

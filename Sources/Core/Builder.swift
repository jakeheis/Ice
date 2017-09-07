//
//  Builder.swift
//  Core
//
//  Created by Jake Heiser on 9/6/17.
//

import Exec
import Regex
import Rainbow

extension SPM {
    
    public func build(release: Bool = false) throws {
        var args = ["build"]
        if release {
            args += ["-c", "release"]
        }
        do {
            try exec(arguments: args).execute(transform: { (t) in
                t.spin("Compile Swift Module '(.*)'", { "Compiling " + $0[0] }, { (spinner, captures, next) in
                    if let next = next, Regex("error: ").matches(next) {
                        spinner.fail(text: "Failed " + captures[0])
                    } else {
                        spinner.succeed(text: "Compiled " + captures[0])
                    }
                })
                t.respond(on: .out, with: ResponseGenerator(matcher: "(/.*):([0-9]+):([0-9]+): (error|warning): (.*)", generate: {
                    return ErrorResponse()
                }))
                t.ignore("^error:", on: .err)
                t.ignore("^terminated\\(1\\)", on: .err)
                t.ignore("^\\s*_\\s*$")
                t.last("\n")
            })
        } catch let error as Exec.Error {
            throw IceError(exitStatus: error.exitStatus)
        }
    }
    
}

private class ErrorResponse: Response {
    
    enum CurrentLine: Int {
        case code
        case underline
        case done
    }
    
    let stream: StdStream = .out
    var fileCaptures: [String] = []
    
    var currentLine: CurrentLine = .code
    var color: Color?
    
    func go(captures: [String]) {
        let prefix: String
        if captures[3] == "error" {
            prefix = "● Error:".red.bold
            color = .red
        } else {
            prefix = "● Warning:".yellow.bold
            color = .yellow
        }
        stream.output("\n  \(prefix) \(captures[4])\n")
        fileCaptures = captures
    }
    
    func keepGoing(on line: String) -> Bool {
        switch currentLine {
        case .code:
            stream.output(line.lightBlack)
            currentLine = .underline
        case .underline:
            stream.output(line.replacingAll(matching: "~", with: "^").applyingColor(color!))
            currentLine = .done
        case .done:
            if let noteMatch = Regex("(/.*):([0-9]+):([0-9]+): note: (.*)").firstMatch(in: line) {
                stream.output("    " + noteMatch.captures[3]! + "\n")
                currentLine = .code
            } else {
                return false
            }
        }
        return true
    }
    
    func stop() {
        let file = fileCaptures[0].trimmingCurrentDirectory
        var components = file.components(separatedBy: "/")
        let last = components.removeLast()
        let coloredFile = components.joined(separator: "/").dim + "/\(last)"
        stream.output("    at \(coloredFile)" + ":\(fileCaptures[1]):\(fileCaptures[2])")
    }
    
    
}

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
                self.transformBuild(t)
                t.last("\n")
            })
        } catch let error as Exec.Error {
            throw IceError(exitStatus: error.exitStatus)
        }
    }
    
    func transformBuild(_ t: OutputTransformer) {
        t.replace("Compile Swift Module '(.*)' (.*)$", {
            return "Compile ".dim + "\($0[0]) \($0[1])"
        })
        t.respond(on: .out, with: ResponseGenerator(matcher: "(/.*):([0-9]+):([0-9]+): (error|warning): (.*)", generate: {
            return ErrorResponse()
        }))
        t.ignore("^error:", on: .err)
        t.ignore("^terminated\\(1\\)", on: .err)
        t.ignore("^\\s*_\\s*$")
        t.replace("Linking (.*)", { "\nLink ".blue + $0[0] })
    }
    
}

private class ErrorResponse: Response {
    
    private static var pastErrors: [[String]] = []
    
    enum CurrentLine: Int {
        case code
        case underline
        case done
    }
    
    var stream: StdStream = .out
    var fileCaptures: [String] = []
    
    var currentLine: CurrentLine = .code
    var color: Color?
    var startIndex: String.Index?
    
    func go(captures: [String]) {
        if ErrorResponse.pastErrors.contains(where: { $0 == captures }) {
            stream = .null
        }
        
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
        
        ErrorResponse.pastErrors.append(captures)
    }
    
    func keepGoing(on line: String) -> Bool {
        switch currentLine {
        case .code:
            startIndex = line.index(where: { $0 != " " })
            stream.output("    " + String(line[startIndex!...]).lightBlack)
            currentLine = .underline
        case .underline:
            stream.output("    " + String(line[startIndex!...]).replacingAll(matching: "~", with: "^").applyingColor(color!))
            currentLine = .done
        case .done:
            if let noteMatch = Regex("(/.*):([0-9]+):[0-9]+: note: (.*)").firstMatch(in: line) {
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
        stream.output("    at \(coloredFile)" + ":\(fileCaptures[1])")
    }
    
    
}

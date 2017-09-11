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
    
    class CompileMatch: RegexMatch {
        var module: String { return captures[0] }
        var sourceCount: String { return captures[1] }
    }
    
    class LinkMatch: RegexMatch {
        var product: String { return captures[0] }
    }
    
    func transformBuild(_ t: OutputTransformer) {
        t.replace("Compile Swift Module '(.*)' (.*)$", CompileMatch.self) {
            "Compile ".dim + "\($0.module) \($0.sourceCount)"
        }
        t.respond(on: .out, with: ResponseGenerator(matcher: "(/.*):([0-9]+):([0-9]+): (error|warning): (.*)", generate: {
            ErrorResponse(match: $0)
        }))
        t.ignore("^error:", on: .err)
        t.ignore("^terminated\\(1\\)", on: .err)
        t.ignore("^\\s*_\\s*$")
        t.replace("Linking (.*)", LinkMatch.self) { "\nLink ".blue + $0.product }
    }
    
}

class ErrorMatch: RegexMatch {
    enum ErrorType: String, Capturable {
        case error
        case warning
    }
    
    var path: String { return captures[0] }
    var lineNumber: Int { return captures[1] }
    var columnNumber: Int { return captures[2] }
    var type: ErrorType { return captures[3] }
    var message: String { return captures[4] }
}

private class ErrorResponse: Response {
    
    typealias Match = ErrorMatch
    
    private static var pastMatches: [Match] = []
    
    enum CurrentLine: Int {
        case code
        case underline
        case done
    }
    
    let match: Match
    
    var stream: StdStream = .out
    var currentLine: CurrentLine = .code
    var color: Color?
    var startIndex: String.Index?
    
    init(match: Match) {
        self.match = match
    }
    
    func go() {
        if ErrorResponse.pastMatches.contains(match) {
            stream = .null
            return
        }
        
        let prefix: String
        switch match.type {
        case .error:
            prefix = "● Error:".red.bold
            color = .red
        case .warning:
            prefix = "● Warning:".yellow.bold
            color = .yellow
        }
        stream.output("\n  \(prefix) \(match.message)\n")
        
        ErrorResponse.pastMatches.append(match)
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
        let file = match.path.trimmingCurrentDirectory
        var components = file.components(separatedBy: "/")
        let last = components.removeLast()
        let coloredFile = components.joined(separator: "/").dim + "/\(last)"
        stream.output("    at \(coloredFile)" + ":\(match.lineNumber)")
    }
    
    
}

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
        try resolve()
        
        var args = ["build"]
        if release {
            args += ["-c", "release"]
        }
        do {
            try exec(arguments: args).execute(transform: { (t) in
                self.transformBuild(t)
            })
        } catch let error as Exec.Error {
            throw IceError(exitStatus: error.exitStatus)
        }
    }
    
    public func run(release: Bool = false) throws {
        try resolve()
        
        var args = ["run"]
        if release {
            args += ["-c", "release"]
        }
        do {
            try exec(arguments: args).execute(transform: { (t) in
                self.transformBuild(t)
            })
        } catch let error as Exec.Error {
            throw IceError(exitStatus: error.exitStatus)
        }
    }
    
    class CompileMatch: RegexMatch, Matchable {
        static let regex = Regex("Compile Swift Module '(.*)' (.*)$")
        var module: String { return captures[0] }
        var sourceCount: String { return captures[1] }
    }
    
    class LinkMatch: RegexMatch, Matchable {
        static let regex = Regex("Linking (.*)")
        var product: String { return captures[0] }
    }
    
    func transformBuild(_ t: OutputTransformer) {
        t.replace(CompileMatch.self) { "Compile ".dim + "\($0.module) \($0.sourceCount)" }
        t.register(ErrorResponse.self, on: .out)
        t.ignore("^error:", on: .err)
        t.ignore("^terminated\\(1\\)", on: .err)
        t.ignore("^\\s*_\\s*$")
        t.replace(LinkMatch.self) { "Link ".blue + $0.product }
    }
    
}

private final class ErrorResponse: SimpleResponse {
    
    class Match: RegexMatch, Matchable {
        static let regex = Regex("(/.*):([0-9]+):([0-9]+): (error|warning): (.*)")
        
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
    
    class NoteMatch: RegexMatch, Matchable {
        static let regex = Regex("(/.*):([0-9]+):[0-9]+: note: (.*)")
        var note: String { return captures[2] }
    }
    
    private static var pastMatches: [Match] = []
    
    enum CurrentLine: Int {
        case code
        case underline
        case done
    }
    
    let match: Match
    let color: Color
    
    var stream: StdStream = .out
    var currentLine: CurrentLine = .code
    var lastLineStartIndex: String.Index?
    
    init(match: Match) {
        self.match = match
        switch match.type {
        case .error:
            self.color = .red
        case .warning:
            self.color = .yellow
        }
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
        case .warning:
            prefix = "● Warning:".yellow.bold
        }
        stream.output("\n  \(prefix) \(match.message)\n")
        
        ErrorResponse.pastMatches.append(match)
    }
    
    func keepGoing(on line: String) -> Bool {
        switch currentLine {
        case .code:
            let lineStartIndex = line.index(where: { $0 != " " }) ?? line.startIndex
            stream.output("    " + String(line[lineStartIndex...]).lightBlack)
            self.lastLineStartIndex = lineStartIndex
            currentLine = .underline
        case .underline:
            let lineStartIndex = self.lastLineStartIndex ?? line.startIndex
            stream.output("    " + String(line[lineStartIndex...]).replacingAll(matching: "~", with: "^").applyingColor(color))
            currentLine = .done
        case .done:
            if let noteMatch = NoteMatch.match(line) {
                stream.output("    note: " + noteMatch.note + "\n")
                currentLine = .code
            } else if line.hasPrefix("        ") {
                let lineStartIndex = self.lastLineStartIndex ?? line.startIndex
                stream.output(String(line[lineStartIndex...]) + "\n")
                return true
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
        stream.output("    at \(coloredFile)" + ":\(match.lineNumber)\n")
    }
    
    
}

//
//  BuildLines.swift
//  Transformers
//
//  Created by Jake Heiser on 9/19/17.
//

import Exec
import Regex
import Rainbow

final class CompileSwiftLine: Line {
    static let regex = Regex("^Compile Swift Module '(.*)' (.*)$")
    static let stream: StandardStream = .out
    
    var module: String { return captures[0] }
    var sourceCount: String { return captures[1] }
}

final class CompileCLine: Line {
    static let regex = Regex("Compile ([^ ]*) .*\\.(c|m|cpp|mm)$")
    static let stream: StandardStream = .out

    var module: String { return captures[0] }
}

final class LinkLine: Line {
    static let regex = Regex("^Linking (.*)")
    static let stream: StandardStream = .out

    var product: String { return captures[0] }
}

final class BuildErrorLine: Line, Equatable {
    static let regex = Regex("^(/.*):([0-9]+):([0-9]+): (error|warning|note): (.*)$")
    static let stream: StandardStream = .out
    
    enum ErrorType: String, Capturable {
        case error
        case warning
        case note
    }
    
    var path: String { return captures[0] }
    var lineNumber: Int { return captures[1] }
    var columnNumber: Int { return captures[2] }
    var type: ErrorType { return captures[3] }
    var message: String { return captures[4] }
}

final class HighlightsLine: Line {
    static let regex = Regex("^([~^ ]+)$")
    static let stream: StandardStream = .out
    var highlights: String { return captures[0] }
}

final class InternalTerminatedErrorLine: Line {
    static let regex = Regex("^error: terminated\\(1\\): (.*)$")
    static let stream: StandardStream = .err
}

final class InternalErrorLine: Line {
    static let regex = Regex("^error: (.*)$")
    static let stream: StandardStream = .err
    var message: String { return captures[0] }
}

final class UnderscoreLine: Line {
    static let regex = Regex("^\\s*_\\s*$")
    static let stream: StandardStream = .out
}

final class TerminatedLine: Line {
    static let regex = Regex("^terminated\\(1\\)")
    static let stream: StandardStream = .err
}

final class WarningsGeneratedLine: Line {
    static let regex = Regex("^[0-9]+ warnings? generated\\.$")
    static let stream: StandardStream = .out
}

typealias CodeLine = AnyErrLine
typealias SuggestionLine = AnyErrLine

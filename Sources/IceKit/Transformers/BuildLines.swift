//
//  BuildLines.swift
//  Transformers
//
//  Created by Jake Heiser on 9/19/17.
//

import Rainbow
import SwiftCLI

final class CompileSwiftLine: Matcher, Matchable {
    static let regex = Regex("^(Compile|\\[\\d+/\\d+\\] Compiling) Swift Module '(.*)' (.*)$")
    var module: String { return captures[1] }
    var sourceCount: String { return captures[2] }
}

final class CompileCLine: Matcher, Matchable {
    static let regex = Regex("^(Compile|\\[\\d+/\\d+\\] Compiling) ([^ ]*) .*\\.(c|m|cpp|mm)$")
    var module: String { return captures[1] }
}

final class LinkLine: Matcher, Matchable {
    static let regex = Regex("^(\\[\\d+/\\d+\\] )?Linking (.*)")
    var product: String { return captures[1] }
}

final class BuildErrorLine: Matcher, Matchable, Equatable {
    
    enum ErrorType: String, ConvertibleFromString {
        case error
        case warning
        case note
    }
    
    static func ==(lhs: BuildErrorLine, rhs: BuildErrorLine) -> Bool {
        return lhs.captures == rhs.captures
    }
    
    static let regex = Regex("^(.*):([0-9]+):([0-9]+): (error|warning|note): (.*)$")
    var path: String { return captures[0] }
    var lineNumber: Int { return captures[1] }
    var columnNumber: Int { return captures[2] }
    var type: ErrorType { return captures[3] }
    var message: String { return captures[4] }
}

final class UnknownErrorLine: Matcher, Matchable {
    static let regex = Regex("^<unknown>:0: (error|warning|note): (.*)$")
    var type: BuildErrorLine.ErrorType { return captures[0] }
    var message: String { return captures[1] }
}

final class HighlightsLine: Matcher, Matchable {
    static let regex = Regex("^([~^ ]+)$")
    var highlights: String { return captures[0] }
}

final class InternalTerminatedErrorLine: Matcher, Matchable {
    static let regex = Regex("^error: terminated\\(1\\): (.*)$")
}

final class UnderscoreLine: Matcher, Matchable {
    static let regex = Regex("^\\s*_\\s*$")
}

final class TerminatedLine: Matcher, Matchable {
    static let regex = Regex("^terminated\\(1\\)")
}

final class WarningsGeneratedLine: Matcher, Matchable {
    static let regex = Regex("^[0-9]+ warnings? generated\\.$")
}

final class LinkerErrorStartLine: Matcher, Matchable {
    static let regex = Regex("^(Undefined symbols.*)$")
    var text: String { return captures[0] }
}

final class LinkerErrorEndLine: Matcher, Matchable {
    static let regex = Regex("^ld:")
}

typealias CodeLine = AnyLine
typealias SuggestionLine = AnyLine

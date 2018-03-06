//
//  Update.swift
//  Transformers
//
//  Created by Jake Heiser on 9/25/17.
//

import Exec
import SwiftCLI
import Regex

public extension Transformers {
    static func update(t: OutputTransformer) {
        t.add(FetchResponse.self)
        t.add(UpdateResponse.self)
        t.add(ResolveResponse.self)
        t.ignore(AnyOutLine.self)
    }
}

final class UpdateResponse: SingleLineResponse {
    static func respond(to line: UpdateLine) {
        stdout <<< "Update ".dim + line.url
    }
}

final class ResolveResponse: SingleLineResponse {
    static func respond(to line: ResolveLine) {
        stdout <<< "Resolve ".dim + "\(line.url) at \(line.version)"
    }
}

// MARK: - Lines

final class UpdateLine: Matcher, StreamMatchable {
    static let regex = Regex("Updating (.*)$")
    static let stream: StandardStream = .out
    
    var url: String { return captures[0] }
}

final class ResolveLine: Matcher, StreamMatchable {
    static let regex = Regex("Resolving (.*) at (.*)$")
    static let stream: StandardStream = .out
    
    var url: String { return captures[0] }
    var version: String { return captures[1] }
}

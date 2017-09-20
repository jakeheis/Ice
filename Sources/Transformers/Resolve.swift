//
//  Resolve.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Exec
import Regex
import Rainbow
import SwiftCLI

public extension Transformers {
    static func resolve(t: OutputTransformer) {
        t.add(FetchResponse.self)
        t.ignore(AnyOutLine.self)
    }
}

final class FetchResponse: SingleLineResponse {
    static func respond(to line: FetchLine) {
        stdout <<< "Fetch ".dim + line.url
    }
}

// MARK: - Lines

final class FetchLine: Line {
    static let regex = Regex("Fetching (.*)$")
    static let stream: StandardStream = .out
    
    var url: String { return captures[0] }
}

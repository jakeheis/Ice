//
//  Resolve.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Exec
import Regex
import Rainbow

public extension Transformers {
    
    static func resolve(t: OutputTransformer) {
        t.replace(ActionMatch.self) { "Fetch ".dim + $0.url }
        t.ignore(".*")
    }
    
}

private class ActionMatch: RegexMatch, Matchable {
    static let regex = Regex("Fetching (.*)$")
    var url: String { return captures[0] }
}

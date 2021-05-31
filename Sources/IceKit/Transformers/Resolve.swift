//
//  Resolve.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Rainbow
import SwiftCLI

extension TransformerPair {
    static var resolve: TransformerPair { return TransformerPair(out: ResolveOut(), err: ResolveErr()) }
}

class ResolveOut: BaseTransformer {
    func go(stream: TransformStream) {
        if let action = stream.match(DependencyActionLine.self) {
            stdout <<< String(describing: action.action).capitalized.dim + " " + action.url
        } else if let resolve = stream.match(ResolveLine.self) {
            stdout <<< "Resolve ".dim + "\(resolve.url) at \(resolve.version)"
        } else if let fetch = stream.match(FetchLine.self) {
            stdout <<< "Fetch ".dim + "\(fetch.url)"
        } else {
            stream.consume()
        }
    }
}

class ResolveErr: BaseTransformer {
    func go(stream: TransformStream) {
        if stream.nextIs(CompletedResolution.self) {
            stream.consume()
        } else if let internalError = stream.match(InternalErrorLine.self) {
            internalError.print(to: stderr)
        } else {
            stderr <<< stream.require(AnyLine.self).text
        }
    }
}

final class CompletedResolution: Matcher, Matchable {
    static let regex = Regex("^Completed resolution")
}

final class DependencyActionLine: Matcher, Matchable {
    enum Action: String, Capturable {
        case update = "Updating"
        case clone = "Cloning"
    }
    static let regex = Regex("(Updating|Cloning) ([^ ]+)$")
    var action: Action { return captures[0] }
    var url: String { return captures[1] }
}

final class FetchLine: Matcher, Matchable {
    static let regex = Regex("Fetching ([^ ]+)( from .*)?$")
    var url: String { return captures[0] }
}

final class ResolveLine: Matcher, Matchable {
    static let regex = Regex("Resolving ([^ ]+) at (.*)$")
    var url: String { return captures[0] }
    var version: String { return captures[1] }
}

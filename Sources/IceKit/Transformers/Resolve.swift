//
//  Resolve.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Rainbow
import Regex
import SwiftCLI

extension TransformerPair {
    static var resolve: TransformerPair { return TransformerPair(out: ResolveOut(), err: ResolveErr()) }
}

class ResolveOut: BaseTransformer {
    func go(stream: TransformStream) {
        if let action = stream.match(DependencyActionLine.self) {
            action.print(to: stdout)
        } else if let resolve = stream.match(ResolveLine.self) {
            resolve.print(to: stdout)
        } else {
            stream.consume()
        }
    }
}

class ResolveErr: BaseTransformer {
    func go(stream: TransformStream) {
        if stream.nextIs(CompletedResolution.self) {
            stream.consume()
        } else {
            stderr <<< stream.require(AnyLine.self).text
        }
    }
}

final class CompletedResolution: Matcher, Matchable {
    static let regex = Regex("^Completed resolution")
}

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
    static var resolve: TransformerPair { return TransformerPair(out: Resolve(), err: nil) }
}

class Resolve: BaseTransformer {
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

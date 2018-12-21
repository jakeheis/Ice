//
//  XC.swift
//  Transformers
//
//  Created by Jake Heiser on 6/3/18.
//

import Rainbow
import SwiftCLI

extension TransformerPair {
    static var xc: TransformerPair { return TransformerPair(out: Xc(), err: nil) }
}

class Xc: BaseTransformer {
    func go(stream: TransformStream) {
        if let action = stream.match(DependencyActionLine.self) {
            action.print(to: stdout)
        } else if let resolve = stream.match(ResolveLine.self) {
            resolve.print(to: stdout)
        } else if let generated = stream.match(GeneratedLine.self) {
            stdout <<< "Generated ".dim + generated.name
        } else {
            stream.consume()
        }
    }
}

// MARK: - Lines

final class GeneratedLine: Matcher, Matchable {
    static let regex = Regex("generated: \\./([^ ]+)$")
    var name: String { return captures[0] }
}

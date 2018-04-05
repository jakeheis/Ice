//
//  Init.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Rainbow
import Regex
import SwiftCLI

public extension TransformerPair {
    static var initialize: TransformerPair { return TransformerPair(out: InitOut(), err: nil) }
}

class InitOut: BaseTransformer {
    func go(stream: TransformStream) {
        if let package = stream.match(CreatePackageLine.self) {
            stdout <<< ""
            stdout <<< package.packageType + ": " + package.packageName.blue.bold
            stdout <<< ""
        } else if let file = stream.match(CreateFileLine.self) {
            stdout <<< "    create ".blue + file.filePath
        }
    }
}

// MARK: - Lines

final class CreatePackageLine: Matcher, Matchable {
    static let regex = Regex("(Creating .* package): (.*)")
    var packageType: String { return captures[0] }
    var packageName: String { return captures[1] }
}

final class CreateFileLine: Matcher, Matchable {
    static let regex = Regex("Creating ([^:]+)$")
    var filePath: String { return captures[0] }
}

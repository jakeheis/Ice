//
//  Init.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Exec
import Regex
import Rainbow
import SwiftCLI

public extension Transformers {
    static func initPackage(t: OutputTransformer) {
        t.add(CreatePackageResponse.self)
        t.add(CreateFileResponse.self)
    }
}

final class CreatePackageResponse: SingleLineResponse {
    static func respond(to line: CreatePackageLine) {
        stdout <<< ""
        stdout <<< line.packageType + ": " + line.packageName.blue.bold
        stdout <<< ""
    }
}

final class CreateFileResponse: SingleLineResponse {
    static func respond(to line: CreateFileLine) {
        stdout <<< "    create ".blue + line.filePath
    }
}

// MARK: - Lines

final class CreatePackageLine: Line {
    static let regex = Regex("(Creating .* package): (.*)")
    static let stream: StandardStream = .out
    
    var packageType: String { return captures[0] }
    var packageName: String { return captures[1] }
}

final class CreateFileLine: Line {
    static let regex = Regex("Creating ([^:]+)$")
    static let stream: StandardStream = .out
    
    var filePath: String { return captures[0] }
}

//
//  Init.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Exec
import Regex
import Rainbow

public extension Transformers {
    
    static func initPackage(t: OutputTransformer) {
        t.first("\n")
        t.replace(CreatingPackageMatch.self) { $0.packageType + ": " + $0.packageName.blue.bold + "\n" }
        t.replace(CreateFileMatch.self) { "    create ".blue + $0.filePath }
        t.last("\n")
    }
    
}

final class CreatingPackageMatch: Matcher {
    static let regex = Regex("(Creating .* package): (.*)")
    var packageType: String { return captures[0] }
    var packageName: String { return captures[1] }
}

final class CreateFileMatch: Matcher {
    static let regex = Regex("Creating ([^:]+)$")
    var filePath: String { return captures[0] }
}

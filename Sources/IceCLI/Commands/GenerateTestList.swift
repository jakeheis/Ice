//
//  GenerateTests.swift
//  Ice
//
//  Created by Samasaur on 11/3/18.
//

import IceKit
import SwiftCLI

class GenerateTestListCommand: IceObject, Command {
    
    let name = "generate-test-list"
    let shortDescription = "Generates Linux test list (XCTestManifests.swift and LinuxMain.swift)"
    
    func execute() throws {
        let package = try loadPackage()
        try SPM().generateTests(for: package.targets)
    }
}

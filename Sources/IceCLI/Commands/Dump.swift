//
//  Dump.swift
//  CLI
//
//  Created by Jake Heiser on 9/6/17.
//

import Foundation
import IceKit
import SwiftCLI

class DumpCommand: Command {
    
    let name = "dump"
    let shortDescription = "Dumps the current package in JSON format"
    
    let model = Flag("-m", "--model", description: "Print the JSON in model form (same output as 'swift package dump-package'); default")
    let packageDescription = Flag("-p", "--package-description", description: "Print the JSON in package description form")
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne(model, packageDescription)]
    }
    
    func execute() throws {
        let mode: SPM.DumpMode = packageDescription.value ? .packageDescription : .model
        let data = try SPM().dumpPackage(mode: mode)
        stdout.writeData(data)
    }
    
}

//
//  Depend.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI
import Core

class DependCommand: Command {

    let name = "depend"
    let shortDescription = "Depends the given target on another target or package"

    let target = Parameter()
    
    let on = Key<String>("-o", "--on")
    var optionGroups: [OptionGroup] {
        return [OptionGroup(options: [on], restriction: .exactlyOne)]
    }

    func execute() throws {
        var package = try Package.load(directory: ".")
        let targets = on.value?.commaSeparated() ?? []
        try targets.forEach { try package.depend(target: target.value, on: $0) }
        try package.write()
    }

}

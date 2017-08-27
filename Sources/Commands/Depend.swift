//
//  Depend.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI

class DependCommand: Command {

    let name = "depend"

    let module = Parameter()
    
    let on = Key<String>("-o", "--on")
    var optionGroups: [OptionGroup] {
        return [OptionGroup(options: [on], restriction: .exactlyOne)]
    }

    func execute() throws {

    }

}
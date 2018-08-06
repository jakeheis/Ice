//
//  Icebox.swift
//  IceTests
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation
import Icebox

class IceConfig: IceboxConfig {
    
    enum Templates: String {
        case json
    }
    
    static let executable = "ice"
    
}

typealias IceBox = Icebox<IceConfig>

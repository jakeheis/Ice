//
//  Logger.swift
//  IceKit
//
//  Created by Jake Heiser on 1/2/19.
//

import SwiftCLI

public enum Logger {
    
    public static var verboseFlag: Flag?
    
    public enum Level: Int {
        case normal
        case verbose
    }
    
    public static var level: Level {
        if verboseFlag?.value == true {
            return .verbose
        }
        return .normal
    }
    
    public static var normal: WritableStream {
        return level.rawValue >= Level.normal.rawValue ? WriteStream.stdout : WriteStream.null
    }
    
    public static var verbose: WritableStream {
        return level.rawValue >= Level.verbose.rawValue ? WriteStream.stdout : WriteStream.null
    }
    
}

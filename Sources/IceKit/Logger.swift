//
//  Logger.swift
//  IceKit
//
//  Created by Jake Heiser on 1/2/19.
//

import Foundation
import SwiftCLI

public enum Logger {
    
    public static let verboseFlag = Flag("-v", "--verbose", description: "Increase verbosity of informational output")
    
    private static let timestampedOut = timestampedStream(for: WriteStream.stdout)
    
    public enum Level: Int {
        case normal
        case verbose
    }
    
    public static var level: Level {
        if verboseFlag.value == true {
            return .verbose
        }
        return .normal
    }
    
    public static var normal: WritableStream {
        return level.rawValue >= Level.normal.rawValue ? timestampedOut : WriteStream.null
    }
    
    public static var verbose: WritableStream {
        return level.rawValue >= Level.verbose.rawValue ? timestampedOut : WriteStream.null
    }
    
    private static func timestampedStream(for destination: WritableStream) -> WritableStream {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return LineStream(each: { (line) in
            destination <<< formatter.string(from: Date()) + ": " + line
        })
    }
    
}

//
//  Hose.swift
//  Exec
//
//  Created by Jake Heiser on 9/5/17.
//

import Foundation
import SwiftCLI
import Dispatch

public enum StdStream {
    case out
    case err
    case null
    
    public func output(_ text: String = "", terminator: String = "\n") {
        switch self {
        case .out:
            print(text, terminator: terminator)
            fflush(stdout)
        case .err:
            printError(text, terminator: terminator)
            fflush(stderr)
        case .null: break
        }
    }
}

class Hose {
    
    let pipe: Pipe
    var onLine: ((_ line: String) -> ())?
    var waitLastLine: String?
    
    init() {
        self.pipe = Pipe()
        self.pipe.fileHandleForReading.readabilityHandler = { (handle) in
            guard let str = String(data: handle.availableData, encoding: .utf8), !str.isEmpty else {
                return
            }
            
            var lines = str.components(separatedBy: "\n")
            if let wait = self.waitLastLine {
                lines[0] = wait + lines[0]
            }
            if let last = lines.last, last.isEmpty {
                lines.removeLast()
                self.waitLastLine = nil
            } else {
                self.waitLastLine = lines.removeLast()
            }
            for line in lines {
                self.onLine?(line)
            }
        }
    }
    
    func attach(_ stream: StdStream, _ process: Process) {
        switch stream {
        case .out: process.standardOutput = pipe
        case .err: process.standardError = pipe
        case .null: break
        }
    }
    
}

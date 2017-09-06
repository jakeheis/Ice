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
    
    public func output(_ text: String, terminator: String = "\n") {
        switch self {
        case .out: print(text, terminator: terminator)
        case .err: printError(text, terminator: terminator)
        }
    }
}

class Hose {
    
    private let pipe: Pipe
    var onLine: ((_ line: String) -> ())?
    
    init() {
        self.pipe = Pipe()
        self.pipe.fileHandleForReading.readabilityHandler = { (handle) in
            guard let str = String(data: handle.availableData, encoding: .utf8), !str.isEmpty else {
                return
            }
            
            DispatchQueue.main.async {
                var lines = str.components(separatedBy: "\n")
                if let last = lines.last, last.isEmpty {
                    lines.removeLast()
                }
                for line in lines {
                    self.onLine?(line)
                }
            }
        }
    }
    
    func attach(_ stream: StdStream, _ process: Process) {
        switch stream {
        case .out: process.standardOutput = pipe
        case .err: process.standardError = pipe
        }
    }
    
}

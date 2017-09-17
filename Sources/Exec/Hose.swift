//
//  Hose.swift
//  Exec
//
//  Created by Jake Heiser on 9/5/17.
//

import Foundation
import SwiftCLI
import Dispatch

infix operator <<<: AssignmentPrecedence

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
    
}

extension Process {
    
    func attachStdout(to hose: Hose) {
        standardOutput = hose.pipe
    }
    
    func attachStderr(to hose: Hose) {
        standardError = hose.pipe
    }
    
}

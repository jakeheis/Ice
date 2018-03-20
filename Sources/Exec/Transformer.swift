//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation
import Regex
import SwiftCLI

// MARK: -

public protocol Transformer {
    func go(stream: PipeStream)
}

public extension Transformer {
    var stdout: OutputByteStream {
        return TransformerConfig.stdout
    }
    var stderr: OutputByteStream {
        return TransformerConfig.stderr
    }
    var rewindCharacter: String {
        return TransformerConfig.rewindCharacter
    }
}

public protocol BaseTransformer: Transformer {}

public extension BaseTransformer {
    
    func start(with pipe: Pipe, semaphore: DispatchSemaphore) {
        DispatchQueue.global().async {
            let stream = PipeStream(pipe: pipe)
            while stream.isOpen() {
                self.go(stream: stream)
            }
            semaphore.signal()
        }
    }
    
}

// MARK: -

public class TransformerPair {
    
    let out: BaseTransformer?
    let err: BaseTransformer?
    private let semaphore: DispatchSemaphore
    private var runningCount = 0
    
    public init(out: BaseTransformer?, err: BaseTransformer?) {
        self.out = out
        self.err = err
        self.semaphore = DispatchSemaphore(value: 0)
    }
    
    func start(on process: Process) {
        if let out = out {
            let pipe = Pipe()
            process.standardOutput = pipe
            out.start(with: pipe, semaphore: semaphore)
            runningCount += 1
        }
        if let err = err {
            let pipe = Pipe()
            process.standardError = pipe
            err.start(with: pipe, semaphore: semaphore)
            runningCount += 1
        }
    }
    
    func wait() {
        for _ in 0..<runningCount {
            semaphore.wait()
        }
    }
    
}

// MARK: -

struct TransformerConfig {
    static var stdout: OutputByteStream = Term.stdout
    static var stderr: OutputByteStream = Term.stderr
    static var rewindCharacter = Term.isTTY ? "\r" : "\n"
    
    private init() {}
}

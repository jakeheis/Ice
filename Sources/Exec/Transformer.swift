//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Dispatch
import Regex
import SwiftCLI

// MARK: -

public protocol Transformer {
    func go(stream: PipeStream)
}

public extension Transformer {
    var stdout: WriteStream {
        return TransformerConfig.stdout
    }
    var stderr: WriteStream {
        return TransformerConfig.stderr
    }
    var rewindCharacter: String {
        return TransformerConfig.rewindCharacter
    }
}

public protocol BaseTransformer: Transformer {}

// MARK: -

public class TransformerPair {
    
    public let out: BaseTransformer?
    public let err: BaseTransformer?
    private let semaphore: DispatchSemaphore
    private var runningCount = 0
    
    public init(out: BaseTransformer?, err: BaseTransformer?) {
        self.out = out
        self.err = err
        self.semaphore = DispatchSemaphore(value: 0)
    }
    
    public func createStdout() -> WriteStream? {
        guard let out = out else { return nil }
        
        let (read, write) = Task.createPipe()
        
        DispatchQueue.global().async { [weak self] in
            let stream = PipeStream(stream: read)
            while stream.isOpen() {
                out.go(stream: stream)
            }
            self?.semaphore.signal()
        }
        
        runningCount += 1
        
        return write
    }
    
    public func createStderr() -> WriteStream? {
        guard let err = err else { return nil }
        
        let (read, write) = Task.createPipe()
        
        DispatchQueue.global().async { [weak self] in
            let stream = PipeStream(stream: read)
            while stream.isOpen() {
                err.go(stream: stream)
            }
            self?.semaphore.signal()
        }
        
        runningCount += 1
        
        return write
    }
    
    public func wait() {
        for _ in 0..<runningCount {
            semaphore.wait()
        }
    }
    
}

// MARK: -

struct TransformerConfig {
    static var stdout: WriteStream = .stdout
    static var stderr: WriteStream = .stderr
    static var rewindCharacter = Term.isTTY ? "\r" : "\n"
    
    private init() {}
}

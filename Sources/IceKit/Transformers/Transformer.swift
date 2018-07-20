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

protocol Transformer {
    func go(stream: TransformStream)
}

extension Transformer {
    var stdout: WritableStream {
        return TransformerConfig.stdout
    }
    var stderr: WritableStream {
        return TransformerConfig.stderr
    }
    var rewindCharacter: String {
        return TransformerConfig.rewindCharacter
    }
}

protocol BaseTransformer: Transformer {}

// MARK: -

class TransformerPair {
    
    let out: BaseTransformer?
    let err: BaseTransformer?
    private let semaphore: DispatchSemaphore
    private var runningCount = 0
    
    init(out: BaseTransformer?, err: BaseTransformer?) {
        self.out = out
        self.err = err
        self.semaphore = DispatchSemaphore(value: 0)
    }
    
    private func createStream(transformer: BaseTransformer) -> WritableStream {
        let pipe = PipeStream()
        
        DispatchQueue.global().async { [weak self] in
            let stream = TransformStream(stream: pipe.readStream)
            while stream.isOpen() {
                transformer.go(stream: stream)
            }
            self?.semaphore.signal()
        }
        
        runningCount += 1
        
        return pipe
    }
    
    func createStdout() -> WritableStream? {
        return out.flatMap(createStream)
    }
    
    func createStderr() -> WritableStream? {
        return err.flatMap(createStream)
    }
    
    func wait() {
        for _ in 0..<runningCount {
            semaphore.wait()
        }
    }
    
    deinit {
        if _isDebugAssertConfiguration() {
            TransformStreamRecord.clear()
        }
    }
    
}

// MARK: -

struct TransformerConfig {
    static var stdout: WritableStream = WriteStream.stdout
    static var stderr: WritableStream = WriteStream.stderr
    static var rewindCharacter = Term.isTTY ? "\r" : "\n"
    
    private init() {}
}

//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Dispatch
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
    
    let stdout: TransformStream?
    let stderr: TransformStream?
    
    init(out: BaseTransformer?, err: BaseTransformer?) {
        self.stdout = out.map({ TransformStream(transformer: $0) })
        self.stderr = err.map({ TransformStream(transformer: $0) })
    }
    
    func wait() {
        stdout?.wait()
        stderr?.wait()
    }
    
    deinit {
        if Logger.level == .verbose {
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

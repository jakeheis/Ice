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
    var stdout: WritableStream { TransformerConfig.stdout }
    var stderr: WritableStream { TransformerConfig.stderr }
    var rewindCharacter: String { TransformerConfig.rewindCharacter }
    var clearLineCharacter: String { TransformerConfig.clearLineCharacter }
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
    static var clearLineCharacter = Term.isTTY ? "\u{001B}[2K\r" : "\n"
    
    private init() {}
}

//
//  TransformerTest.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

import XCTest
import SwiftCLI
import Rainbow
@testable import Exec

class TransformerTest {
    
    let transformer: Transformer
    let pipe: (read: ReadStream, write: WriteStream)
    let primaryCapture: CaptureStream
    let secondaryCapture: CaptureStream
    
    init(transformer: Transformer, isStdout: Bool) {
        self.transformer = transformer
        self.pipe = Task.createPipe()
        self.primaryCapture = CaptureStream()
        self.secondaryCapture = CaptureStream()
        
        TransformerConfig.rewindCharacter = "\n"
        Rainbow.enabled = false
        if isStdout {
            TransformerConfig.stdout = self.primaryCapture
            TransformerConfig.stderr = self.secondaryCapture
        } else {
            TransformerConfig.stdout = self.secondaryCapture
            TransformerConfig.stderr = self.primaryCapture
        }
    }
    
    func send(_ contents: String) {
        pipe.write <<< contents
    }
    
    func expect(_ content: String, file: StaticString = #file, line: UInt = #line) {
        pipe.write.close()
        
        let stream = PipeStream(stream: pipe.read)
        while stream.isOpen() {
            transformer.go(stream: stream)
        }
        
        primaryCapture.close()
        secondaryCapture.close()
        
        XCTAssertEqual(primaryCapture.awaitContent(), content, file: file, line: line)
        XCTAssertEqual(secondaryCapture.awaitContent(), "", file: file, line: line)
    }
    
}

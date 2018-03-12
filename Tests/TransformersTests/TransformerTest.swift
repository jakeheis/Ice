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
    let pipe: Pipe
    let primaryCapture: CaptureStream
    let secondaryCapture: CaptureStream
    
    init(transformer: Transformer, isStdout: Bool) {
        self.transformer = transformer
        self.pipe = Pipe()
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
        pipe.fileHandleForWriting.write((contents + "\n").data(using: .utf8)!)
    }
    
    func expect(_ content: String, file: StaticString = #file, line: UInt = #line) {
        pipe.fileHandleForWriting.closeFile()
        
        let stream = PipeStream(pipe: pipe)
        while stream.isOpen() {
            transformer.go(stream: stream)
        }
        
        XCTAssertEqual(self.primaryCapture.content, content, file: file, line: line)
        XCTAssertEqual(self.secondaryCapture.content, "", file: file, line: line)
    }
    
}

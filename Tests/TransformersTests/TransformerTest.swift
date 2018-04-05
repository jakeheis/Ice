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
    let feeder: PipeStream
    let primaryCapture: PipeStream
    let secondaryCapture: PipeStream
    
    init(transformer: Transformer, isStdout: Bool) {
        self.transformer = transformer
        self.feeder = PipeStream()
        self.primaryCapture = PipeStream()
        self.secondaryCapture = PipeStream()
        
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
        feeder <<< contents
    }
    
    func expect(_ content: String, file: StaticString = #file, line: UInt = #line) {
        feeder.closeWrite()
        
        let stream = TransformStream(stream: feeder)
        while stream.isOpen() {
            transformer.go(stream: stream)
        }
        
        primaryCapture.closeWrite()
        secondaryCapture.closeWrite()
        
        XCTAssertEqual(primaryCapture.readAll(), content, file: file, line: line)
        XCTAssertEqual(secondaryCapture.readAll(), "", file: file, line: line)
    }
    
}

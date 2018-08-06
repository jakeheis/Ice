//
//  TransformerTest.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

import XCTest
import SwiftCLI
import Rainbow
@testable import IceKit

class TransformerTest {
    
    let transformStream: TransformStream
    let primaryCapture: PipeStream
    let secondaryCapture: PipeStream
    
    init(transformer: Transformer, isStdout: Bool) {
        self.transformStream = TransformStream(transformer: transformer)
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
        transformStream <<< contents
    }
    
    func send(mac macContents: String, linux linuxContents: String) {
        transformStream <<< macContents
    }
    
    func expect(_ content: String, file: StaticString = #file, line: UInt = #line) {
        transformStream.closeWrite()
        transformStream.wait()
        
        primaryCapture.closeWrite()
        secondaryCapture.closeWrite()
        
        XCTAssertEqual(primaryCapture.readAll(), content, file: file, line: line)
        XCTAssertEqual(secondaryCapture.readAll(), "", file: file, line: line)
    }
    
}

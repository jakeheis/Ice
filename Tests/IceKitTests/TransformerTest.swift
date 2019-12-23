//
//  TransformerTest.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

@testable import IceKit
import Rainbow
import SwiftCLI
import TestingUtilities
import XCTest

class TransformerTest {
    
    let transformStream: TransformStream
    let primaryCapture: CaptureStream
    let secondaryCapture: CaptureStream
    
    init(transformer: Transformer, isStdout: Bool) {
        self.transformStream = TransformStream(transformer: transformer)
        self.primaryCapture = CaptureStream()
        self.secondaryCapture = CaptureStream()
        
        TransformerConfig.rewindCharacter = "\n"
        TransformerConfig.clearLineCharacter = "\n"
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
        
        IceAssertEqual(primaryCapture.readAll(), content, file: file, line: line)
        IceAssertEqual(secondaryCapture.readAll(), "", file: file, line: line)
    }
    
}

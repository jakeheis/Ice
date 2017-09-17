//
//  TransformersTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

import XCTest
import SwiftCLI
import Rainbow
@testable import Exec
@testable import Transformers

class TransformTest {
    
    let transformer: OutputTransformer
    let stdoutCapture: CaptureStream
    let stderrCapture: CaptureStream
    
    var stdout: String {
        return stdoutCapture.content
    }
    
    var stderr: String {
        return stderrCapture.content
    }

    init(_ transform: @escaping (OutputTransformer) -> ()) {
        self.stdoutCapture = CaptureStream()
        self.stderrCapture = CaptureStream()
        
        OutputTransformer.stdout = self.stdoutCapture
        OutputTransformer.stderr = self.stderrCapture
        Rainbow.enabled = false
        
        let transformer = OutputTransformer()
        transform(transformer)
        self.transformer = transformer
        
        self.transformer.printPrefix()
    }

    func send(_ stream: StandardStream, _ contents: String) {
        let hose: Hose
        switch stream {
        case .out: hose = transformer.out
        case .err: hose = transformer.error
        }
        
        let lines = contents.components(separatedBy: "\n")
        
        for line in lines {
            hose.onLine?(line)
        }
    }

    func expect(stdout: String, stderr: String, file: StaticString = #file, line: UInt = #line) {
        self.transformer.printSuffix()
        
        XCTAssertEqual(self.stdout, stdout, file: file, line: line)
        XCTAssertEqual(self.stderr, stderr, file: file, line: line)
    }
    
}


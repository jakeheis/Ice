//
//  TransformersTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

import XCTest
import SwiftCLI
@testable import Exec
@testable import Transformers

class TransformTest {
    
    let transformer: OutputTransformer
    let stdoutCapture: CaptureStream
    let stderrCapture: CaptureStream

    init(_ transform: @escaping (OutputTransformer) -> ()) {
        self.stdoutCapture = CaptureStream()
        self.stderrCapture = CaptureStream()
        
        OutputTransformer.stdout = self.stdoutCapture
        OutputTransformer.stderr = self.stderrCapture
        
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
        
        XCTAssertEqual(self.stdoutCapture.content, stdout, file: file, line: line)
        XCTAssertEqual(self.stderrCapture.content, stderr, file: file, line: line)
    }
    
}


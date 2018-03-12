//
//  Test.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Foundation
import Exec
import Regex
import Rainbow
import SwiftCLI

public extension TransformerPair {
    static var test: TransformerPair { return TransformerPair(out: TestOut(), err: TestErr()) }
}

class TestOut: BaseTransformer {
    
    static var onLine: ((String) -> ())? = nil
    
    func go(stream: PipeStream) {
        let text = stream.require(AnyLine.self).text + "\n"
        TestOut.onLine?(text)
    }
    
}

class TestErr: BaseTransformer {
    
    var firstPass = true
    
    func go(stream: PipeStream) {
        if matchPotentialError(stream: stream) {
            return
        }
        
        let mode = stream.require(AllTestsStartLine.self).mode
        
        let packageTests = stream.require(PackageTestsStartLine.self)
        if firstPass {
            stderr <<< "\n\(packageTests.packageName):\n".bold
            firstPass = false
        }
        
        var failureCount = 0
        while stream.nextIs(TestSuiteLine.self, where: { $0.status == .started }) {
            let suite = TestSuite(mode: mode)
            suite.go(stream: stream)
            failureCount += suite.failureCount
        }
        
        _ = stream.require(AllTestsEndLine.self) // .xctest done
        _ = stream.require(TestCountLine.self) // .xctest timing
        
        _ = stream.require(AllTestsEndLine.self) // all tests done
        let count = stream.require(TestCountLine.self)
        
        printInfo(fails: failureCount, total: count.totalCount, duration: count.duration)
    }
    
    private func matchPotentialError(stream: PipeStream) -> Bool {
        if let internalError = stream.match(InternalErrorLine.self) {
            internalError.print(to: stderr)
            return true
        } else if let internalNote = stream.match(InternalNoteLine.self) {
            stderr <<< ""
            let message = internalNote.message.contains("--filter") ? "filter predicate did not match any test case" : internalNote.message
            stderr <<< "Error: ".bold.red + message
            stderr <<< ""
            return true
        }
        return false
    }
    
    private func printInfo(fails: Int, total: Int, duration: String) {
        var parts: [String] = []
        if fails > 0 {
            parts.append("\(fails) failed".bold.red)
        }
        if fails < total {
            parts.append("\(total - fails) passed".bold.green)
        }
        parts.append("\(total) total")
        
        stderr <<< ""
        stderr <<< "Tests:\t".bold.white + parts.joined(separator: ", ")
        stderr <<< "Time:\t".bold.white + duration + "s"
        stderr <<< ""
    }
    
}

class TestSuite: Transformer {
    
    let mode: AllTestsStartLine.SuiteMode
    var failureCount = 0
    var name = ""
    
    init(mode: AllTestsStartLine.SuiteMode) {
        self.mode = mode
    }
    
    func go(stream: PipeStream) {
        let start = stream.require(TestSuiteLine.self)
        
        if let firstTestCase = stream.peek(TestCaseLine.self) {
            name = "\(firstTestCase.targetName)." + start.suiteName
            if mode == .selected {
                name += "/\(firstTestCase.caseName)"
            }
            stderr.output(badge(text: "RUNS", color: .blue), terminator: "")
            fflush(Foundation.stderr)
        }
        while stream.nextIs(TestCaseLine.self) {
            TestCase(suite: self).go(stream: stream)
        }
        
        _ = stream.require(TestSuiteLine.self)
        _ = stream.require(TestCountLine.self)
        
        if failureCount == 0 {
            stderr <<< rewindCharacter + badge(text: "PASS", color: .green)
        }
    }
    
    func markFailed() {
        failureCount += 1
        if failureCount == 1 {
            stderr <<< rewindCharacter + badge(text: "FAIL", color: .red)
            stderr <<< ""
        }
    }
    
    private func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + name.bold
    }
    
}

class TestCase: Transformer {
    
    private weak var suite: TestSuite?
    private var failed = false
    
    init(suite: TestSuite) {
        self.suite = suite
    }
    
    func go(stream: PipeStream) {
        var otherOutput = ""
        TestOut.onLine = { (line) in
            otherOutput += line
        }
        
        let testCase = stream.require(TestCaseLine.self)
        
        while !stream.nextIs(TestCaseLine.self) {
            if stream.nextIs(AssertionFailureLine.self) {
                printFailed(testCase: testCase.caseName)
                AssertionFailure().go(stream: stream)
            } else {
                otherOutput += stream.require(AnyLine.self).text + "\n"
            }
        }
        
        TestOut.onLine = nil
        
        if failed {
            if !otherOutput.isEmpty {
                stderr <<< "\tOutput:"
                stderr <<< otherOutput.components(separatedBy: "\n").map({ "\t\($0)" }).joined(separator: "\n").dim
            }
        }
        
        _ = stream.require(TestCaseLine.self)
    }
    
    private func printFailed(testCase: String) {
        if !failed {
            failed = true
            suite?.markFailed()
            stderr <<< " ● \(testCase)".red.bold
        }
    }
    
}

class AssertionFailure: Transformer {
    
    static let newlineReplacement = "______$$$$$$$$"
    
    func go(stream: PipeStream) {
        let failure = stream.require(AssertionFailureLine.self)
        
        var assertion = failure.assertion
        while !stream.nextIs(in: [AssertionFailureLine.self, FatalErrorLine.self, TestCaseLine.self]) && stream.isOpen() {
            assertion += AssertionFailure.newlineReplacement + stream.require(AnyLine.self).text
        }
        
        stderr <<< ""
        var foundMatch = false
        
        for matchType in xctMatches {
            if let match = matchType.findMatch(in: assertion) {
                match.print(to: stderr)
                
                if !match.message.isEmpty {
                    stderr <<< ""
                    let lines = match.message.components(separatedBy: AssertionFailure.newlineReplacement)
                    var message = lines[0]
                    if lines.count > 1 {
                        message += "\n" + lines.dropFirst().map({ "\t\($0)" }).joined(separator: "\n")
                    }
                    stderr <<< "\tNote: \(message)"
                }
                
                foundMatch = true
                break
            }
        }
        
        if !foundMatch {
            stderr <<< "\tError: ".red + assertion
        }
        
        let fileLocation = failure.file.beautifyPath
        stderr <<< ""
        stderr <<< "\tat \(fileLocation):\(failure.lineNumber)".dim
        stderr <<< ""
    }
    
}

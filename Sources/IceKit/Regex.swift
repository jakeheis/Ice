//
//  Regex.swift
//  IceKit
//
//  Created by Jake Heiser on 12/21/18.
//

import Foundation

public struct Regex {
    
    let regularExpression: NSRegularExpression
    
    public init(_ pattern: StaticString, options: NSRegularExpression.Options = []) {
        do {
            regularExpression = try NSRegularExpression(pattern: pattern.description, options: options)
        } catch {
            preconditionFailure("invalid Regex")
        }
    }
    
    public init(unsafePattern: String, options: NSRegularExpression.Options = []) {
        do {
            regularExpression = try NSRegularExpression(pattern: unsafePattern, options: options)
        } catch {
            preconditionFailure("invalid Regex")
        }
    }
    
    public func matches(_ string: String) -> Bool {
        return firstMatch(in: string) != nil
    }
    
    public func firstMatch(in string: String) -> MatchResult? {
        let match = regularExpression
            .firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            .map { MatchResult(string, $0) }
        return match
    }
    
    public func allMatches(in string: String) -> [MatchResult] {
        let matches = regularExpression
            .matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            .map { MatchResult(string, $0) }
        return matches
    }
    
}

public struct MatchResult {
    
    let captureRanges: [Range<String.Index>?]
    let captures: [String?]
    
    init(_ parent: String, _ result: NSTextCheckingResult) {
        captureRanges = (1..<result.numberOfRanges).map { (index) in
            let range = result.range(at: index)
            return Range(range, in: parent)
        }
        
        captures = captureRanges.map { (range) in
            if let range = range {
                return String(parent[range])
            }
            return nil
        }
    }
    
}

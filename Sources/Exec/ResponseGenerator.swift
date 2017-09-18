//
//  ResponseGenerator.swift
//  Exec
//
//  Created by Jake Heiser on 9/17/17.
//

import Regex

public class ResponseGenerator {
    
    private let regex: Regex
    private let generate: (String) -> Response
    
    public convenience init<T: SimpleResponse>(_ type: T.Type) {
        self.init(type, generate: { (match) in
            return T(match: match)
        })
    }
    
    public convenience init<T: MatchedResponse>(_ type: T.Type, generate: @escaping (T.Match) -> T) {
        self.init(regex: T.Match.regex, generate: { (line) in
            guard let match = T.Match.findMatch(in: line) else {
                fatalError("generateResponse should only be called if a match is guaranteed")
            }
            return generate(match)
        })
    }
    
    public convenience init(regex: StaticString, generate: @escaping (String) -> Response) {
        self.init(regex: Regex(regex), generate: generate)
    }
    
    public init(regex: Regex, generate: @escaping (String) -> Response) {
        self.regex = regex
        self.generate = generate
    }
    
    public func matches(_ line: String) -> Bool {
        return regex.matches(line)
    }
    
    public func generateResponse(to line: String) -> Response {
        return generate(line)
    }
    
}

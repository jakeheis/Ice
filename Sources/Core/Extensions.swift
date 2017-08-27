//
//  Extensions.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation

public extension String {
    var quoted: String {
        return "\"\(self)\""
    }
}

public extension URLSession {
    static func synchronousDataTask(with url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        var retVal: (data: Data?, response: URLResponse?, error: Error?)? = nil
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            retVal = (data, response, error)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return retVal!
    }
}

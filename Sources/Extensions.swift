//
//  Extensions.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation

extension String {
    var quoted: String {
        return "\"\(self)\""
    }
}

extension URLSession {
    
    /// Return data from synchronous URL request
    static func synchronousDataTask(with url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
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

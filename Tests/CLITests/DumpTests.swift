//
//  DumpTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class DumpTests: XCTestCase {
    
    static var allTests = [
        ("testDump", testDump),
    ]
    
    func testDump() {
        let result = Runner.execute(args: ["dump"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        {
          "cLanguageStandard": null,
          "cxxLanguageStandard": null,
          "dependencies": [
            {
              "requirement": {
                "lowerBound": "3.0.3",
                "type": "range",
                "upperBound": "4.0.0"
              },
              "url": "https://github.com/jakeheis/SwiftCLI"
            }
          ],
          "name": "Exec",
          "products": [

          ],
          "targets": [
            {
              "dependencies": [
                {
                  "name": "SwiftCLI",
                  "type": "byname"
                }
              ],
              "exclude": [

              ],
              "isTest": false,
              "name": "Exec",
              "path": null,
              "publicHeadersPath": null,
              "sources": null
            }
          ]
        }
        
        
        """)
    }
    
}

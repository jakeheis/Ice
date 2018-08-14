//
//  DumpTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class DumpTests: XCTestCase {
    
    static var allTests = [
        ("testDump", testDump),
    ]
    
    func testDump() {
        let result = IceBox(template: .exec).run("dump")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        differentiatedAssertEquality(result.stdout, swift4_2AndAbove: """
        {
          "cLanguageStandard": null,
          "cxxLanguageStandard": null,
          "dependencies": [
            {
              "requirement": {
                "lowerBound": "4.0.3",
                "type": "range",
                "upperBound": "5.0.0"
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
              "name": "Exec",
              "path": null,
              "publicHeadersPath": null,
              "sources": null,
              "type": "regular"
            }
          ]
        }
        """, swift4_0AndAbove: """
        {
          "cLanguageStandard": null,
          "cxxLanguageStandard": null,
          "dependencies": [
            {
              "requirement": {
                "lowerBound": "4.0.3",
                "type": "range",
                "upperBound": "5.0.0"
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

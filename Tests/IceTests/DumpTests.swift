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
        let result = IceBox(template: .exec).run("dump")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        // TODO: swift(>=4.2) doesn't work here for some reason, so using 4.1.3 even though that version doesn't exist
        #if swift(>=4.1.3)
        XCTAssertEqual(result.stdout, """
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
        """)
        #else
        XCTAssertEqual(result.stdout, """
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
        #endif
    }
    
}

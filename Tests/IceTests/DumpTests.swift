//
//  DumpTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class DumpTests: XCTestCase {
    
    func testModel() {
        let result = IceBox(template: .exec).run("dump")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        
        Differentiate.byVersion(swift5AndAbove: {
            IceAssertEqual(result.stdout, """
            {
              "cLanguageStandard" : null,
              "cxxLanguageStandard" : null,
              "dependencies" : [
                {
                  "requirement" : {
                    "range" : [
                      {
                        "lowerBound" : "4.0.3",
                        "upperBound" : "5.0.0"
                      }
                    ]
                  },
                  "url" : "https:\\/\\/github.com\\/jakeheis\\/SwiftCLI"
                }
              ],
              "manifestVersion" : "v4",
              "name" : "Exec",
              "pkgConfig" : null,
              "products" : [

              ],
              "providers" : null,
              "swiftLanguageVersions" : null,
              "targets" : [
                {
                  "dependencies" : [
                    {
                      "byName" : [
                        "SwiftCLI"
                      ]
                    }
                  ],
                  "exclude" : [

                  ],
                  "name" : "Exec",
                  "settings" : [

                  ],
                  "type" : "regular"
                }
              ]
            }
            """)
        }, swift4_2AndAbove: {
            IceAssertEqual(result.stdout, """
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
        }, swift4_0AndAbove: {
            IceAssertEqual(result.stdout, """
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
        })
    }
    
    /*
    func testPackageDescription() {
        let result = IceBox(template: .exec).run("dump", "-p")
        
        Differentiate.byPlatform(mac: {
            IceAssertEqual(result.exitStatus, 0)
            IceAssertEqual(result.stderr, "")
            Differentiate.byVersion(swift5AndAbove: {
                IceAssertEqual(result.stdout, """
                {"package":{"products":[],"cxxLanguageStandard":null,"swiftLanguageVersions":null,"providers":null,"pkgConfig":null,"targets":[{"name":"Exec","dependencies":[{"type":"byname","name":"SwiftCLI"}],"sources":null,"providers":null,"pkgConfig":null,"path":null,"publicHeadersPath":null,"exclude":[],"type":"regular"}],"dependencies":[{"url":"https:\\/\\/github.com\\/jakeheis\\/SwiftCLI","requirement":{"type":"range","lowerBound":"4.0.3","upperBound":"5.0.0"}}],"name":"Exec","cLanguageStandard":null},"errors":[]}
                """)
            }, swift4_2AndAbove: {
                IceAssertEqual(result.stdout, """
                {"errors": [], "package": {"cLanguageStandard": null, "cxxLanguageStandard": null, "dependencies": [{"requirement": {"lowerBound": "4.0.3", "type": "range", "upperBound": "5.0.0"}, "url": "https://github.com/jakeheis/SwiftCLI"}], "name": "Exec", "products": [], "targets": [{"dependencies": [{"name": "SwiftCLI", "type": "byname"}], "exclude": [], "name": "Exec", "path": null, "publicHeadersPath": null, "sources": null, "type": "regular"}]}}
                """)
            }, swift4_0AndAbove: {
                IceAssertEqual(result.stdout, """
                {"errors": [], "package": {"cLanguageStandard": null, "cxxLanguageStandard": null, "dependencies": [{"requirement": {"lowerBound": "4.0.3", "type": "range", "upperBound": "5.0.0"}, "url": "https://github.com/jakeheis/SwiftCLI"}], "name": "Exec", "products": [], "targets": [{"dependencies": [{"name": "SwiftCLI", "type": "byname"}], "exclude": [], "isTest": false, "name": "Exec", "path": null, "publicHeadersPath": null, "sources": null}]}}
                """)
            })
        }, linux: {
            IceAssertEqual(result.exitStatus, 1)
            IceAssertEqual(result.stdout, "")
            IceAssertEqual(result.stderr, """

            Error: dumping package description is not supported on Linux


            """)
        })
        
    }*/
    
}

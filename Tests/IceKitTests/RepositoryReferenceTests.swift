//
// RepositoryReferenceTests.swift
// IceKitTests
//

import XCTest
import IceKit

class RepositoryReferenceTests: XCTestCase {
    
    static var allTests = [
        ("testGithub", testGithub),
        ("testGitlab", testGitlab),
        ("testMostRecentVersion", testMostRecentVersion),
    ]
    
    func testGithub() {        
        let short = RepositoryReference(blob: "jakeheis/SwiftCLI")
        XCTAssertEqual(short?.url, "https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(short?.name, "SwiftCLI")
        
        let mid = RepositoryReference(blob: "gh:jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.url, "https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.name, "SwiftCLI")
        
        let full = RepositoryReference(blob: "https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.url, "https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.name, "SwiftCLI")
        
        let fullGit = RepositoryReference(blob: "https://github.com/jakeheis/SwiftCLI.git")
        XCTAssertEqual(fullGit?.url, "https://github.com/jakeheis/SwiftCLI.git")
        XCTAssertEqual(fullGit?.name, "SwiftCLI")
        
        let ssh = RepositoryReference(blob: "git@github.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.url, "git@github.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.name, "SwiftCLI")
    }
    
    func testGitlab() {
        let mid = RepositoryReference(blob: "gl:jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.url, "https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.name, "SwiftCLI")
        
        let full = RepositoryReference(blob: "https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.url, "https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.name, "SwiftCLI")
        
        let ssh = RepositoryReference(blob: "git@gitlab.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.url, "git@gitlab.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.name, "SwiftCLI")
    }
    
    func testMostRecentVersion() throws {
        let ref = RepositoryReference(blob: "jakeheis/Alamofire")
        let latest = try ref?.latestVersion()
        XCTAssertEqual(latest, Version("3.4.1"))
    }
    
}

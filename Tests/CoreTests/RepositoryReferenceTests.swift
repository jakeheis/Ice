//
// RepositoryReferenceTests.swift
// Ice
//

import XCTest
import Core

class RepositoryReferenceTests: XCTestCase {
    
    static var allTests = [
        ("testGithub", testGithub),
        ("testGitlab", testGitlab),
        ("testMostRecentVersion", testMostRecentVersion),
    ]
    
    func testGithub() {
        let short = RepositoryReference("jakeheis/SwiftCLI")
        XCTAssertEqual(short?.url, "https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(short?.name, "SwiftCLI")
        
        let mid = RepositoryReference("gh:jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.url, "https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.name, "SwiftCLI")
        
        let full = RepositoryReference("https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.url, "https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.name, "SwiftCLI")
        
        let fullGit = RepositoryReference("https://github.com/jakeheis/SwiftCLI.git")
        XCTAssertEqual(fullGit?.url, "https://github.com/jakeheis/SwiftCLI.git")
        XCTAssertEqual(fullGit?.name, "SwiftCLI")
        
        let ssh = RepositoryReference("git@github.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.url, "git@github.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.name, "SwiftCLI")
    }
    
    func testGitlab() {
        let mid = RepositoryReference("gl:jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.url, "https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssertEqual(mid?.name, "SwiftCLI")
        
        let full = RepositoryReference("https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.url, "https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssertEqual(full?.name, "SwiftCLI")
        
        let ssh = RepositoryReference("git@gitlab.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.url, "git@gitlab.com:jakeheis/SwiftCLI.git")
        XCTAssertEqual(ssh?.name, "SwiftCLI")
    }
    
    func testMostRecentVersion() {
        let ref = RepositoryReference("jakeheis/Alamofire")
        let latest = try! ref?.latestVersion()
        XCTAssertEqual(latest, Version("3.4.1"))
    }
    
}

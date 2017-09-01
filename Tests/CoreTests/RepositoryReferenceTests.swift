//
// RepositoryReferenceTests.swift
// Ice
//

import XCTest
import Core

class RemoteTests: XCTestCase {
    
    func testGithub() {
        let short = RepositoryReference("jakeheis/SwiftCLI")
        XCTAssert(short?.url == "https://github.com/jakeheis/SwiftCLI")
        XCTAssert(short?.name == "SwiftCLI")
        
        let mid = RepositoryReference("gh:jakeheis/SwiftCLI")
        XCTAssert(mid?.url == "https://github.com/jakeheis/SwiftCLI")
        XCTAssert(mid?.name == "SwiftCLI")
        
        let full = RepositoryReference("https://github.com/jakeheis/SwiftCLI")
        XCTAssert(full?.url == "https://github.com/jakeheis/SwiftCLI")
        XCTAssert(full?.name == "SwiftCLI")
        
        let fullGit = RepositoryReference("https://github.com/jakeheis/SwiftCLI.git")
        XCTAssert(fullGit?.url == "https://github.com/jakeheis/SwiftCLI.git")
        XCTAssert(fullGit?.name == "SwiftCLI")
        
        let ssh = RepositoryReference("git@github.com:jakeheis/SwiftCLI.git")
        XCTAssert(ssh?.url == "git@github.com:jakeheis/SwiftCLI.git")
        XCTAssert(ssh?.name == "SwiftCLI")
    }
    
    func testGitlab() {
        let mid = RepositoryReference("gl:jakeheis/SwiftCLI")
        XCTAssert(mid?.url == "https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssert(mid?.name == "SwiftCLI")
        
        let full = RepositoryReference("https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssert(full?.url == "https://gitlab.com/jakeheis/SwiftCLI")
        XCTAssert(full?.name == "SwiftCLI")
        
        let ssh = RepositoryReference("git@gitlab.com:jakeheis/SwiftCLI.git")
        XCTAssert(ssh?.url == "git@gitlab.com:jakeheis/SwiftCLI.git")
        XCTAssert(ssh?.name == "SwiftCLI")
    }
    
    func testMostRecentVersion() {
        let ref = RepositoryReference("jakeheis/Alamofire")
        let latest = try! ref?.latestVersion()
        XCTAssert(latest == Version("3.4.1"))
    }
    
}

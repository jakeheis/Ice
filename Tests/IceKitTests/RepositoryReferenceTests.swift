//
// RepositoryReferenceTests.swift
// IceKitTests
//

import IceKit
import XCTest

class RepositoryReferenceTests: XCTestCase {
    
    func testGithub() {        
        let short = RepositoryReference(blob: "jakeheis/SwiftCLI", registry: MockRegistry())
        IceAssertEqual(short?.url, "https://github.com/jakeheis/SwiftCLI")
        IceAssertEqual(short?.name, "SwiftCLI")
        
        let mid = RepositoryReference(blob: "gh:jakeheis/SwiftCLI", registry: MockRegistry())
        IceAssertEqual(mid?.url, "https://github.com/jakeheis/SwiftCLI")
        IceAssertEqual(mid?.name, "SwiftCLI")
        
        let full = RepositoryReference(blob: "https://github.com/jakeheis/SwiftCLI", registry: MockRegistry())
        IceAssertEqual(full?.url, "https://github.com/jakeheis/SwiftCLI")
        IceAssertEqual(full?.name, "SwiftCLI")
        
        let fullGit = RepositoryReference(blob: "https://github.com/jakeheis/SwiftCLI.git", registry: MockRegistry())
        IceAssertEqual(fullGit?.url, "https://github.com/jakeheis/SwiftCLI.git")
        IceAssertEqual(fullGit?.name, "SwiftCLI")
        
        let ssh = RepositoryReference(blob: "git@github.com:jakeheis/SwiftCLI.git", registry: MockRegistry())
        IceAssertEqual(ssh?.url, "git@github.com:jakeheis/SwiftCLI.git")
        IceAssertEqual(ssh?.name, "SwiftCLI")
    }
    
    func testGitlab() {
        let mid = RepositoryReference(blob: "gl:jakeheis/SwiftCLI", registry: MockRegistry())
        IceAssertEqual(mid?.url, "https://gitlab.com/jakeheis/SwiftCLI")
        IceAssertEqual(mid?.name, "SwiftCLI")
        
        let full = RepositoryReference(blob: "https://gitlab.com/jakeheis/SwiftCLI", registry: MockRegistry())
        IceAssertEqual(full?.url, "https://gitlab.com/jakeheis/SwiftCLI")
        IceAssertEqual(full?.name, "SwiftCLI")
        
        let ssh = RepositoryReference(blob: "git@gitlab.com:jakeheis/SwiftCLI.git", registry: MockRegistry())
        IceAssertEqual(ssh?.url, "git@gitlab.com:jakeheis/SwiftCLI.git")
        IceAssertEqual(ssh?.name, "SwiftCLI")
    }
    
    func testMostRecentVersion() throws {
        let ref = RepositoryReference(blob: "jakeheis/Alamofire", registry: MockRegistry())
        let latest = try ref?.latestVersion()
        IceAssertEqual(latest, Version("3.4.1"))
    }
    
}

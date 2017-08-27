
//
//  RemotePackage.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation

// import Files

struct PackageInstaller {

    static func install(url: String, destination: String) throws {
        // git clone \(url) \(destination)

        let spm = SPM(path: destination)
        try spm.build()
    }

}

struct LocalPackage {

    let name: String
    let url: String
    let versions: [Version]

    // var folder: Folder {
        
    // }

    static func find(name: String) throws -> LocalPackage {
        throw SwiftProcess.Error.processFailed
    }

    func install(version: Version) {
//        try PackageInstaller.install(url: url, destination: folder.path + version)
    }

}

public struct RepositoryTag: Decodable {
    let name: String
}

struct RemotePackage {

    let name: String
    let url: String
    let version: String

    static func resolve(name: String, version: String? = nil) throws -> RemotePackage {
        throw SwiftProcess.Error.processFailed

        /*let fullUrl = "https://github.com/\(name)"
        if package.dependencies.contains(where: { $0.url == fullUrl }) {
            print("Dependency already exists")
            throw SwiftProcess.Error.processFailed
        }
        
        var major: Int?
        var minor: Int?
        
        if let tagUrl = URL(string: "https://api.github.com/repos/\(name)/tags") {
            let (data, _, _) = URLSession.synchronousDataTask(with: tagUrl)
            if let data = data,
                let tags = try? JSONDecoder().decode([RepositoryTag].self, from: data) {
                let versions = tags.flatMap { Version.init($0.name) }.filter { $0.patch.index(of: "-") == nil }.sorted()
                if let mostRecent = versions.last {
                    major = mostRecent.major
                    minor = mostRecent.minor
                }
            }
        }
        
        if major == nil {
            print("Major version:", terminator: "")
            major = Int(readLine()!)
            print("Minor version (blank for any):", terminator: "")
            minor = Int(readLine()!)
        }*/
    }

    @discardableResult
    func install() throws -> LocalPackage {
        throw SwiftProcess.Error.processFailed
    }

}

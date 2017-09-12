//
//  Build.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import Dispatch
import Foundation
import Files

class BuildCommand: Command {
    
    let name = "build"
    let shortDescription = "Builds the current project"
    
    let clean = Flag("-c", "--clean")
    let release = Flag("-r", "--release")
    let watch = Flag("-w", "--watch")
    
    func execute() throws {
        let spm = SPM()
        
        if clean.value {
            try spm.clean()
        }
        
        if !watch.value {
            try spm.build(release: release.value)
            return
        }
        
        let rebuilder = try Rebuilder(spm: spm)
        rebuilder.go()
    }
    
}

class Rebuilder {
    
    let spm: SPM
    let observer: DirectoryObserver
    var needsRebuild = true
    
    let rebuildQueue = DispatchQueue(label: "com.jakeheis.Ice.Rebuilder")
    
    init(spm: SPM) throws {
        self.spm = spm
        self.observer = try DirectoryObserver(path: "Sources")
    }
    
    func go() {
        observer.start {
            self.rebuildQueue.async {
                self.needsRebuild = true
            }
        }
        while true {
            sleep(1)
            rebuildIfNecessary()
        }
    }
    
    
    func rebuildIfNecessary() {
        rebuildQueue.async {
            if self.needsRebuild {
                do {
                    print("Rebuilding...")
                    try self.spm.build()
                } catch {}
            }
            self.needsRebuild = false
        }
    }
    
}

class DirectoryObserver {
    
    let queue = DispatchQueue(label: "com.jakeheis.Ice.FileObserver")
    let observers: [FileObserver]
    
    init(path: String) throws {
        var observers: [FileObserver] = []
        observers.append(FileObserver(path: path, queue: queue))
        let paths = try FileManager.default.subpathsOfDirectory(atPath: path)
        for subpath in paths {
            if let folder = try? Folder(path: path + "/" + subpath) {
                observers.append(FileObserver(path: folder.path, queue: queue))
            } else if let file = try? File(path: path + "/" + subpath), file.extension == "swift" {
                observers.append(FileObserver(path: file.path, queue: queue))
            }
        }
        self.observers = observers
    }
    
    func start(onEvent: @escaping () -> ()) {
        for observer in observers {
            observer.start(onEvent: onEvent)
        }
    }
    
}

class FileObserver {
    
    let path: String
    let source: DispatchSourceFileSystemObject
    
    init(path: String, queue: DispatchQueue) {
        self.path = path
        
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor > 0 else {
            fatalError("Couldn't open file \(path)")
        }
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: [.write, .delete], queue: queue)
    }
    
    func start(onEvent: @escaping () -> ()) {
        self.source.setEventHandler(handler: onEvent)
        source.resume()
    }
    
}

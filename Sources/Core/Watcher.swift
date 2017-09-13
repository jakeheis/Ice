//
//  Watcher.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/12/17.
//

import Dispatch
import Foundation
import Files

public class Watcher {
    
    let action: () -> ()
    private let observer: DirectoryObserver
    private var needsAction = true
    
    private let watchQueue = DispatchQueue(label: "com.jakeheis.Ice.Watcher")
    
    public init(action: @escaping () -> ()) throws {
        self.action = action
        self.observer = try DirectoryObserver(path: "Sources")
    }
    
    public func go() {
        observer.start {
            self.watchQueue.async {
                self.needsAction = true
            }
        }
        while true {
            sleep(1)
            actIfNecessary()
        }
    }
    
    private func actIfNecessary() {
        watchQueue.async {
            if self.needsAction {
                self.action()
            }
            self.needsAction = false
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


//
//  SourceWatcher.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/12/17.
//

import Dispatch
import PathKit

public class SourceWatcher {
    
    let action: () -> ()
    private var watchers: [DispatchSourceFileSystemObject] = []
    private var startOver = true
    private var needsAction = true
    private var lastChildren: Set<String> = []
    
    private let watchQueue = DispatchQueue(label: "com.jakeheis.Ice.SourceWatcher")
    
    public init(action: @escaping () -> ()) throws {
        self.action = action
    }
    
    public func go() throws -> Never {
        while true {
            actIfNecessary()
            sleep(1)
        }
    }
    
    private func startWatch() throws {
        let path: Path
        let sources = Path("Sources")
        let source = Path("Source")
        if sources.exists && sources.isDirectory {
            path = sources
        } else if source.exists && source.isDirectory {
            path = source
        } else {
            throw IceError(message: "couldn't find source directory to watch")
        }
        
        let children = try path.recursiveChildren().filter { $0.isDirectory || $0.extension == "swift" }
        for child in children {
            let handle = open(child.string, O_EVTONLY)
            let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: handle, eventMask: [.delete, .write, .link, .rename, .revoke], queue: watchQueue)
            source.setEventHandler {
                if child.isDirectory {
                    let newChildren = (try? path.recursiveChildren().filter { $0.isDirectory || $0.extension == "swift" }.map({ $0.string })) ?? []
                    if !self.lastChildren.symmetricDifference(newChildren).isEmpty {
                        self.startOver = true
                        self.needsAction = true
                        self.lastChildren = Set(newChildren)
                    }
                } else {
                    self.needsAction = true
                }
            }
            source.setCancelHandler {
                close(handle)
            }
            source.resume()
            watchers.append(source)
            lastChildren.insert(child.string)
        }
    }
    
    private func actIfNecessary() {
        watchQueue.async {
            if self.startOver {
                self.watchers.forEach { $0.cancel() }
                self.watchers.removeAll()
                do {
                    try self.startWatch()
                } catch {
                    exit(1)
                }
            }
            if self.needsAction {
                self.action()
            }
            self.startOver = false
            self.needsAction = false
        }
    }
    
}

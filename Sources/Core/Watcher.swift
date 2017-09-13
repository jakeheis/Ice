//
//  Watcher.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/12/17.
//

import Dispatch
import FileKit

public class Watcher {
    
    let action: () -> ()
    private var watcher: FileSystemWatcher?
    private var needsAction = true
    
    private let watchQueue = DispatchQueue(label: "com.jakeheis.Ice.Watcher")
    
    public init(action: @escaping () -> ()) throws {
        self.action = action
    }
    
    public func go() {
        let sources = Path("Sources")
        let children = sources.children(recursive: true).filter { $0.isDirectory || $0.pathExtension == "swift" }
        let watcher = FileSystemWatcher(paths: [sources] + children) { (event) in
            self.watchQueue.async {
                self.needsAction = true
            }
        }
        watcher.watch()
        self.watcher = watcher
        
        while true {
            sleep(1)
            watcher.flushSync()
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

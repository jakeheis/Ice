# Ice

The package manager Swift deserves. 100% compatible with Swift Package Manager

### Motivation

The official [Swift Package Manager](https://github.com/apple/swift-package-manager) is great at actually managing packages (resolving package versions, compiling source, etc.), but it lacks in developer friendliness. Ice uses Swift Package Manger in its core, but provides a much more developer friendly layer on top of SPM.

### FAQ

##### Why use Swift Package Manager at all? Why not write an entirely new package manager?

A goal of Ice is to retain 100% compatibilty with SPM -- the goal is not to splinter the ecosystem in any way. By building Ice on top of SPM, we can easily attain that goal.

##### Why not contribute these improvements directly to SPM rather than creating a new layer on top of it?

Swift Package Manager has considered some of the improvements offered in Ice but rejected them (for now). Notably, SPM chose to keep the package manager within the `swift` executable, meaning that commands are often quite verbose. I believe that cleaning a package should not require the user to type `swift package clean`.

Having said that, it's my hope that Ice can be a proving ground for some of these features, a place where they can be fine-tuned and eventually can make their way into SPM core. Ideally, Ice will one day be unnecessary.

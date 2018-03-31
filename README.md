# Ice

[![Build Status](https://travis-ci.org/jakeheis/Ice.svg?branch=master)](https://travis-ci.org/jakeheis/Ice)

❄️ A developer friendly package manager for Swift; 100% compatible with Swift Package Manager

### Motivation

The official [Swift Package Manager](https://github.com/apple/swift-package-manager) is great at actually managing packages (resolving package versions, compiling source, etc.), but it lacks in developer friendliness. Ice uses Swift Package Manger in its core, but provides a much more developer friendly layer on top of SPM.

A few features Ice has that SPM lacks:
- Beautiful, yet information dense output (particularly while building and testing)
- Ability to imperatively manage `Package.swift` (e.g. `ice add RxSwift`)
- A centralized registry of packages
- Automatic rebuilding / restarting of an app upon source changes
- Short command names for the most used commands

## Installation
### [Mint](https://github.com/yonaskolb/mint) (recommended)

```bash
mint install jakeheis/Ice
```

### Homebrew

```bash
brew install jakeheis/repo/ice
```

### Manual

```bash
git clone https://github.com/jakeheis/Ice
cd Ice
swift build -c release
ln -s .build/release/ice /usr/bin/local/ice
```

## Better output

### Init
![new](https://github.com/jakeheis/Ice/raw/gifs/new.gif)

### Build
![build](https://github.com/jakeheis/Ice/raw/gifs/build.gif)

### Test
![test](https://github.com/jakeheis/Ice/raw/gifs/test.gif)

## Imperatively manage `Package.swift`

Manage dependencies:

```shell
ice add RxSwift
ice add Alamofire 4.5.1
ice add jakeheis/SwiftCLI
ice remove Alamofire
```

Manage targets:

```shell
ice target add Core
ice target add --test CoreTests --dependencies Core
ice target remove CoreTests
```

Manage products:

```shell
ice product add CoreLib --static
ice product add cli --exec --targets=CoreLib
ice product remove CoreLib
```

## Centralized package registry

The built in registry (https://github.com/jakeheis/IceRegistry) consists of the most-starred Swift repositories on Github. You get these for free, but you can also add your own personal entries to a local registry:

```shell
> ice registry lookup Alamofire
https://github.com/Alamofire/Alamofire
> ice registry add https://github.com/jakeheis/SwiftCLI SwiftCLI
> ice registry lookup SwiftCLI
https://github.com/jakeheis/SwiftCLI
```

Once packages are in the registry (either the shared registry or your local registry), you can refer to them just by the project name:

```shell
> ice add Alamofire
> ice add SwiftCLI
```

## Automatic rebuilding / restarting

`ice build` and `ice run` both accept a watch flag which instructs them to rebuild/restart your app whenever a source file changes:

```shell
> ice build -w
[ice] rebuilding due to changes...
Compile CLI (20 sources)

  ● Error: use of unresolved identifier 'dsf'

    dsf
    ^^^
    at Sources/CLI/Target.swift:74

[ice] rebuilding due to changes...
Compile CLI (20 sources)
Link ./.build/x86_64-apple-macosx10.10/debug/ice
```

```shell
> ice run -w
[ice] restarting due to changes...
```

## Other commands

#### ice outdated

Check if any dependencies are outdated

```shell
> ice outdated
+-----------------+-----------------+----------+--------+
| Name            | Wanted          | Resolved | Latest |
+-----------------+-----------------+----------+--------+
| FileKit         | 4.1.0 ..< 5.0.0 | 4.1.1    | 4.1.1  |
| Rainbow         | 3.1.1 ..< 4.0.0 | 3.1.1    | 3.1.1  |
| Regex           | 1.1.0 ..< 2.0.0 | 1.1.0    | 1.1.0  |
| SwiftCLI        | 4.0.0 ..< 5.0.0 | 4.0.3    | 4.0.4  |
| SwiftyTextTable | 0.8.0 ..< 1.0.0 | 0.8.0    | 0.8.0  |
+-----------------+-----------------+----------+--------+
```

#### ice update
Update the current package's dependencies

```shell
> ice update
Update https://github.com/jakeheis/SwiftCLI
Resolve https://github.com/jakeheis/SwiftCLI at 4.0.4
> ice update SwiftCLI 5.0.0
```

#### ice clean
Clean the current project by removing build artifacts

#### ice reset
Remove everything in the `.build` folder (build artifacts, checked out dependencies, etc.)

#### ice init
Initialize a new package in the current directory

#### ice dump
Dump the current package as JSON

#### ice describe Alamofire
Describe the package in the registry with the name "Alamofire"

#### ice search CLI
Search for packages in the registry with "CLI" in their name or description

#### ice xc
Generate an Xcode project for the current project and open it

#### ice config get/set
Configure Ice behavior. Recognized keys:
- reformat: when writing `Package.swift`, should Ice reformat the file to be alphabetized

## FAQ

#### Can I use Ice and SPM side by side?
Yes! Because Ice is built on SPM, you can seamlessly go back and forth between `ice` and `swift` commands.

#### Why does Ice internally use Swift Package Manager at all? Why not write an entirely new package manager?

A goal of Ice is to retain 100% compatibilty with SPM -- Ice should not splinter the ecosystem in any way. By building Ice on top of SPM, we can easily attain that goal.

#### Why not contribute these improvements directly to SPM rather than creating a new layer on top of it?

Swift Package Manager has considered some of the improvements offered in Ice but rejected them (for now). Notably, SPM chose to keep the package manager within the `swift` executable, meaning that commands are often quite verbose. I believe that tasks as common as cleaning a package should not require the user to type commands as lengthy as `swift package clean`.

Having said that, it's my hope that Ice can be a proving ground for some of these features, a place where they can be fine-tuned and eventually can make their way into SPM core. Ideally, Ice will one day be unnecessary.

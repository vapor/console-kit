<p align="center">
<img src="https://cloud.githubusercontent.com/assets/1342803/16251041/b927cf44-37f0-11e6-9255-055ab471b1cd.png" width="826" align="middle"/>
</p>

# Swift Console

![Swift](http://img.shields.io/badge/swift-v3.0--dev.08.18-brightgreen.svg)
[![Build Status](https://travis-ci.org/vapor/console.svg?branch=master)](https://travis-ci.org/vapor/console)
[![CircleCI](https://circleci.com/gh/vapor/console.svg?style=shield)](https://circleci.com/gh/vapor/console)
[![Code Coverage](https://codecov.io/gh/vapor/console/branch/master/graph/badge.svg)](https://codecov.io/gh/vapor/console)
[![Codebeat](https://codebeat.co/badges/a793ad97-47e3-40d9-82cf-2aafc516ef4e)](https://codebeat.co/projects/github-com-vapor-console)
[![Slack Status](http://vapor.team/badge.svg)](http://vapor.team)

A Swift wrapper for Console I/O.

- [x] Terminal Colors
- [x] User Input
- [x] Threads and Animations

## Example

Create a terminal console, or create a new type of console that conforms to the `Console` protocol.

```swift
let console = Terminal()
```

### Ask

```swift
let name = console.ask("What is your name?")

console.print("Hello, \(name).")
```

### Confirm

```swift
if console.confirm("Are you sure?") {
	// user is sure	
}
```

### Styles

```swift
console.warning("Watch out!")
```

```swift
public enum ConsoleStyle {
    case plain
    case success
    case info
    case warning
    case error
    case custom(ConsoleColor)
}
```

### Colors

```swift
console.output("Cool colors.", style: .custom(.magenta))
```

```swift
public enum ConsoleColor {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
}
```

### Progress Bar

For showing loading with progress updates.

```swift
let filename = "filename.txt"

let progressBar = console.progressBar(title: filename)
progress.start()

fakeClient.download(progressCallback: { progress in
	progressBar.progress = progress	
}, completionCallback: { file in 
	progressBar.finish()
})
```

```shell
filename.txt [====           ] 23%
```

### Loading Bar

For showing loading of indeterminate length.

```swift
let filename = "filename.txt"

let loadingBar = console.loadingBar(title: "Connecting")
loadingBar.start()

fakeServer.connect(completionCallback: { connection in 
	loadingBar.finish()
})
```

```shell
Connecting [         •     ]
```

### Travis

Travis builds this package on both Ubuntu 14.04 and macOS 10.11. Check out the `.travis.yml` file to see how this package is built and compiled during testing.

## 🌏 Environment

|Console|Xcode|Swift|
|:-:|:-:|:-:|
|0.7.x|8.0 GM|DEVELOPMENT-SNAPSHOT-2016-09-06-a|
|0.6.x|8.0 Beta **6**|DEVELOPMENT-SNAPSHOT-2016-08-18-a|
|0.5.x|8.0 Beta **3**|DEVELOPMENT-SNAPSHOT-2016-07-25-a|
|0.4.x|8.0 Beta **3**|DEVELOPMENT-SNAPSHOT-2016-07-20-qutheory|
|0.3.x|8.0 beta **2**|3.0-PREVIEW-2|
|0.2.x|8.0 beta **2**|3.0-PREVIEW-2|
|0.1.x|7.3.x|DEVELOPMENT-SNAPSHOT-2016-06-20-a|

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.qutheory.io) for instructions on how to install Swift 3. 

## 💧 Community

We pride ourselves on providing a diverse and welcoming community. Join your fellow Vapor developers in [our slack](slack.qutheory.io) and take part in the conversation.

## 🔧 Compatibility

Node has been tested on OS X 10.11, Ubuntu 14.04, and Ubuntu 15.10.

## 👥 Author

Created by [Tanner Nelson](https://github.com/tannernelson).

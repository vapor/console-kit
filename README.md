<p align="center">
<img src="https://cloud.githubusercontent.com/assets/1342803/16251041/b927cf44-37f0-11e6-9255-055ab471b1cd.png" width="826" align="middle"/>
</p>

# Swift Console

![Swift](https://camo.githubusercontent.com/0727f3687a1e263cac101c5387df41048641339c/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d332e302d6f72616e67652e7376673f7374796c653d666c6174)
[![Build Status](https://travis-ci.org/qutheory/console.svg?branch=master)](https://travis-ci.org/qutheory/console)

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

### Loading Bar

For showing loading of indeterminate length.

```swift
let filename = "filename.txt"

let loadingBar = console.loadingBar(title: "Connecting")
progress.start()

fakeServer.connect(completionCallback: { connection in 
	loadingBar.finish()
})
```

### Travis

Travis builds this package on both Ubuntu 14.04 and macOS 10.11. Check out the `.travis.yml` file to see how this package is built and compiled during testing.

## Vapor

This wrapper was created to power [Vapor](https://github.com/qutheory/vapor), a Web Framework for Swift. 

## Author

Created by [Tanner Nelson](https://github.com/tannernelson).

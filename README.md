<p align="center">
<img src="https://design.vapor.codes/images/vapor-consolekit.svg" height="96" alt="ConsoleKit">
<br>
<br>
<a href="https://docs.vapor.codes/4.0/"><img src="https://design.vapor.codes/images/readthedocs.svg" alt="Documentation"></a>
<a href="https://discord.gg/vapor"><img src="https://design.vapor.codes/images/discordchat.svg" alt="Team Chat"></a>
<a href="LICENSE"><img src="https://design.vapor.codes/images/mitlicense.svg" alt="MIT License"></a>
<a href="https://github.com/vapor/console-kit/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/vapor/console-kit/test.yml?event=push&style=plastic&logo=github&label=tests&logoColor=%23ccc" alt="Continuous Integration"></a>
<a href="https://codecov.io/github/vapor/console-kit"><img src="https://img.shields.io/codecov/c/github/vapor/console-kit?style=plastic&logo=codecov&label=codecov"></a>
<a href="https://swift.org"><img src="https://design.vapor.codes/images/swift61up.svg" alt="Swift 6.1+"></a>
</p>

<br>

💻 Utilities for interacting with a terminal and the command line in a Swift application.

### Supported Platforms

ConsoleKit supports all platforms supported by Swift 6.1 and later.

### Installation

Use the SPM string to easily include the dependendency in your `Package.swift` file

```swift
.package(url: "https://github.com/vapor/console-kit.git", from: "5.0.0")
```

and add it to your target's dependencies:

```swift
.product(name: "ConsoleKit", package: "console-kit")
```

## Overview

`ConsoleKit` provides utilities for interacting with a console in a Swift application. It provides:

* Utilities for sending text (including styles and colors, when supported) to a terminal.
* Utilities for reading input from a terminal.
* ``ConsoleLogger``, a [SwiftLog](https://github.com/apple/swift-log) `LogHandler` implementation for customizable logging to a console.

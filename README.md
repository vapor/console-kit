<div align="center">
<img src="https://design.vapor.codes/images/vapor-consolekit.svg" height="96" alt="ConsoleKit">
<br>

[![Documentation](https://design.vapor.codes/images/readthedocs.svg)](https://docs.vapor.codes/4.0/)
[![Team Chat](https://design.vapor.codes/images/discordchat.svg)](https://discord.gg/vapor)
[![MIT License](https://design.vapor.codes/images/mitlicense.svg)](LICENSE)
[![Continuous Integration](https://img.shields.io/github/actions/workflow/status/vapor/console-kit/test.yml?event=push&style=plastic&logo=github&label=tests&logoColor=ccc)](https://github.com/vapor/console-kit/actions/workflows/test.yml)
[![Code Coverage](https://img.shields.io/codecov/c/gh/vapor/console-kit?style=plastic&logo=codecov&label=codecov)](https://codecov.io/gh/vapor/console-kit)
[![Swift 6.2+](https://design.vapor.codes/images/swift62up.svg)](https://swift.org)

</div>

<br>

💻 Utilities for interacting with a terminal and the command line in a Swift application.

## Overview

`ConsoleKit` provides utilities for interacting with a console in a Swift application. It provides:

* Utilities for sending text (including styles and colors, when supported) to and reading input from a terminal.
* `ConsoleLogger`, a [SwiftLog](https://github.com/apple/swift-log) `LogHandler` implementation for customizable logging to a console.

### Supported Platforms

ConsoleKit supports all platforms supported by Swift 6.2 and later.

### Installation

Use the Github repository URL to add the dependency to your `Package.swift` manifest:

```swift
.package(url: "https://github.com/vapor/console-kit.git", from: "5.0.0")
```

### CLI Tools

To use `ConsoleKit`, add it to your target's dependencies:

```swift
.product(name: "ConsoleKit", package: "console-kit")
```

### Logging

`ConsoleLogger` is a flexible logging backend for console applications, allowing developers to customize log output with various fragments, including timestamps, log levels, and source locations.

To use `ConsoleLogger`, add it to your target's dependencies:

```swift
.product(name: "ConsoleLogger", package: "console-kit")
```

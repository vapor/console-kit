# ``ConsoleKitCommands``

@Metadata {
    @TitleHeading(Package)
}

ConsoleKit provides utilities for interacting with a console via a Swift application. It provides:

* A ``Command`` type for writing commands with arguments and flags
* Utilities for sending and receiving text to a terminal
* A [Swift Log](https://github.com/apple/swift-log) implementation for a ``Logger`` that outputs to the console

> Note: At this time, the argument handling capabilities of ConsoleKit are considered obsolete; using [ArgumentParser](https://github.com/apple/swift-argument-parser.git) instead is recommended where practical.

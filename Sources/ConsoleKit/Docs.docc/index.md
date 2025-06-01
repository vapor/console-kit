# ``ConsoleKit``

@Metadata {
    @TitleHeading(Package)
}

💻 APIs for creating interactive CLI tools.

## Overview

`ConsoleKit` provides utilities for interacting with a console in a Swift application. It provides:

* Utilities for sending text (including styles and colors, when supported) to a terminal.
* Utilities for reading input from a terminal.
* ``ConsoleLogger`` and ``ConsoleFragmentLogger``, [SwiftLog](https://github.com/apple/swift-log) `LogHandler` implementations for customizable logging to a console.

## Topics

### Terminal

- ``Console``
- ``Terminal``
- ``ConsoleColor``
- ``ConsoleStyle``
- ``ConsoleClear``
- ``ConsoleText``
- ``ConsoleTextFragment``
- ``+(_:_:)``
- ``+=(_:_:)``
- ``ConsoleKit/Swift/StringProtocol``

### Activity

- ``ActivityIndicator``
- ``ActivityIndicatorType``
- ``ActivityIndicatorState``
- ``ActivityBar``
- ``LoadingBar``
- ``ProgressBar``
- ``CustomActivity``

### Logging

- ``ConsoleLogger``
- ``ConsoleFragmentLogger``
- ``LoggerFragment``
- ``LogRecord``
- ``FragmentOutput``
- ``IfMaxLevelFragment``
- ``AndFragment``
- ``LabelFragment``
- ``LevelFragment``
- ``LiteralFragment``
- ``SeparatorFragment``
- ``MessageFragment``
- ``MetadataFragment``
- ``SourceLocationFragment``
- ``LoggerSourceFragment``
- ``TimestampSource``
- ``SystemTimestampSource``
- ``TimestampFragment``
- ``defaultLoggerFragment()``
- ``timestampDefaultLoggerFragment(timestampSource:)``
- ``ConsoleKit/Logging``
# Getting Started with ConsoleLogger

Customize your logging output in Swift console applications using `ConsoleLogger`, a flexible `SwiftLog` backend.

## Overview

`SwiftLog` provides a unified, performant, and ergonomic logging API that can be adopted by libraries and applications across the Swift ecosystem.
`ConsoleLogger` is a logging backend for `SwiftLog` that outputs log messages to the console with customizable formatting.

The building blocks of `ConsoleLogger` are ``LoggerFragment``s, which represent individual components of a log message, such as the log level, timestamp, message content, and source location.
By combining these fragments into other fragments, developers can create tailored log outputs that suit their application's needs.

You then pass the resulting fragment to the ``ConsoleLogger``, which is a `SwiftLog` `LogHandler` implementation that formats and outputs log messages to the console based on the provided fragment structure.

### Default LoggerFragments

`ConsoleLogger` includes a couple of default ``LoggerFragment``s that can be used out of the box:

- ``LoggerFragment/default``, which outputs the label of the logger, the level of the logged message, the logged message itself, the metadata and the file location of the logged message, including the line.
- ``LoggerFragment/timestampDefault(timestampSource:)``, which adds a timestamp at the front of the default fragment.

### Creating a LoggerFragment

You can create your own ``LoggerFragment`` to customize your log output by combining existing fragments.
As an example, here's how to recreate the ``LoggerFragment/default`` fragment starting from the base fragments:

```swift
let myDefaultLoggerFragment = LabelFragment().maxLevel(.trace)
    .and(LevelFragment().separated(" ").and(MessageFragment().separated(" ")))
    .and(MetadataFragment().separated(" "))
    .and(SourceLocationFragment().separated(" ").maxLevel(.debug))
```

There's also a much more ergonomic declarative syntax to build fragments using result builders.
Here's the same default fragment built with the result builder syntax:

```swift
let myDefaultLoggerFragment = SpacedFragment {
    LabelFragment().maxLevel(.trace)
    LevelFragment()
    MessageFragment()
    MetadataFragment()
    SourceLocationFragment().maxLevel(.debug)
}
```

There are a handful of modifiers you can apply to fragments to further customize them, such as:

- ``LoggerFragment/maxLevel(_:)``, which limits the maximum log level at which the fragment will be included in the output.
- ``LoggerFragment/prefixed(_:)``, which adds a prefix string to the fragment output.
- ``LoggerFragment/suffixed(_:)``, which adds a suffix string to the fragment output.
- ``LoggerFragment/and(_:)``, which combines two fragments together. If you use the result builder syntax, the fragments will be combined automatically.
- ``LoggerFragment/separated(_:)``, which adds a separator string before the fragment output. ``SpacedFragment`` automatically combines fragments with a single space separator.

Here's a list of all the fragments available out of the box in `ConsoleLogger`:

- ``IfMaxLevelFragment``
- ``AndFragment``
- ``OptionalFragment``
- ``ArrayFragment``
- ``LabelFragment``
- ``LevelFragment``
- ``LiteralFragment``
- ``SeparatorFragment``
- ``SpacedFragment``
- ``MessageFragment``
- ``MetadataFragment``
- ``SourceLocationFragment``
- ``LoggerSourceFragment``
- ``TimestampFragment``

Keep in mind that you can also create your own custom fragments by conforming to the ``LoggerFragment`` protocol.

### Bootstrapping the LoggingSystem

Build a ``ConsoleLogger`` with a custom or default fragment and register it with the `LoggingSystem`:

```swift
LoggingSystem.bootstrap(fragment: .timestampDefault())

// Prints "2023-08-21T00:00:00Z [ INFO ] Logged!"
Logger(label: "EXAMPLE").info("Logged!")
```

You can also create multiple loggers with different labels and fragments as needed.

```swift
let logger = Logger(label: "codes.vapor.console") { label in
    ConsoleLogger(label: label) {
        SpacedFragment {
            "ConsoleLogger" // This is equivalent to LiteralFragment("ConsoleLogger")
            LabelFragment()
            LevelFragment()
            MessageFragment()
        }
    }
}

logger.warning("This is a warning message.")
```

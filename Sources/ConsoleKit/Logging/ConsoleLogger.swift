import Logging
import class Foundation.ISO8601DateFormatter
import struct Foundation.Date

/// Outputs logs to a `Console`.
public struct ConsoleLogger: LogHandler {
    /// See `Logger.label`.
    public let label: String

    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata

    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level

    /// The console that the messages will get logged to.
    public let console: Console

    /// The output configuration which applies to the logger backed by this handler. Initially, a copy of the default
    /// configuration provided when boostrapping the logging system, but can be updated to change the output behavior of
    /// the individual `Logger`.
    public var outputConfiguration: Logger.OutputConfiguration = .default

    /// The style configuration which applies to the logger backed by this handler. Initially, a copy of the default
    /// configuration provided when boostrapping the logging system, but can be updated to change the style of the
    /// individual `Logger`.
    public var styleConfiguration: Logger.StyleConfiguration = .default

    /// Creates a new `ConsoleLogger` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    ///   - settings: The output configuration this logger should use. This defaults to the default console logger settings.
    ///   - style: The style configuration this logger should use. This defaults to the default console logger style.
    ///
    /// - Note: It would make more sense for the output and style configurations to default to those provided when
    ///   bootstrapping the logging system (if any). Unfortunately, it was not possible to do this without either
    ///   breaking existing API or taking the performance hit of a global lock on every logger creation.
    public init(
        label: String,
        console: Console,
        level: Logger.Level = .debug,
        metadata: Logger.Metadata = [:],
        settings: Logger.OutputConfiguration = .default,
        style: Logger.StyleConfiguration = .default
    ) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
        self.outputConfiguration = settings
        self.styleConfiguration = style
    }

    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
        set { self.metadata[key] = newValue }
    }

    /// See `LogHandler.log(level:message:metadata:source:file:function:line:)`.
    ///
    /// - Important: Due to https://github.com/apple/swift-log/issues/145, we currently ignore the `source` parameter,
    ///   even if it has been manually specified with a non-default value. This will be changed in the future.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        /// - TODO: Preallocate a medium-sized buffer that can be reused for building log messages instead of glomming ConsoleTexts together.
        var text: ConsoleText = ""
        
        // Note: The use of `" ".consoleText(self.styleConfiguration.baseStyle)` and similar constructs seems pointless at
        //       first glance, but its necessity becomes immediately obvious after, for example, giving each of the styles
        //       a different (and non-default) background color.
        // TODO: Don't torment the construction of the consoleText pieces so much. This can be done ENORMOUSLY more efficiently.

        // Render the timestamp if currently visible.
        if self.outputConfiguration.timestampDisplayLogLevel.map({ $0 >= self.logLevel }) ?? false {
            text += "[".consoleText(self.styleConfiguration.baseStyle) +
                    "\(self.outputConfiguration.timestampLoggingFormat.render(at: Date()))"
                        .consoleText(self.styleConfiguration.timestampStyle ?? self.styleConfiguration.baseStyle) +
                    "] ".consoleText(self.styleConfiguration.baseStyle)
        }

        // Render the label if currently visible.
        if self.outputConfiguration.labelDisplayLogLevel.map({ $0 >= self.logLevel }) ?? false {
            text += "[ ".consoleText(self.styleConfiguration.baseStyle) +
                    "\(self.label)".consoleText(self.styleConfiguration.labelStyle ?? self.styleConfiguration.baseStyle) +
                    " ] ".consoleText(self.styleConfiguration.baseStyle)
        }

        // Render the level and message (always visible).
        text += "[ ".consoleText(self.styleConfiguration.baseStyle) +
                "\(level.rawValue.uppercased())".consoleText(self.styleConfiguration.levelStyles[level] ?? self.styleConfiguration.baseStyle) +
                " ]".consoleText(self.styleConfiguration.baseStyle) +
                " ".consoleText(self.styleConfiguration.baseStyle) +
                "\(message)".consoleText(self.styleConfiguration.messageStyle ?? self.styleConfiguration.baseStyle)

        // Render the metadata if currently visible _and_ nonempty.
        if self.outputConfiguration.metadataDisplayLogLevel.map({ $0 >= self.logLevel }) ?? false,
           let allMetadata = self.mergeMetadata(with: metadata)
        {
            text += " [".consoleText(self.styleConfiguration.baseStyle) +
            // TODO: In the overwhelmingly common case where the metadata is just `self.metadata`, the sorting and rendering of
            // the description can be cached in `subscript(metdata:).setter` instead of repeated every time a message is logged.
                    "\(allMetadata.sorted(by: { $0.key < $1.key }).map { "\($0.description): \($1)" }.joined(separator: ", "))"
                        .consoleText(self.styleConfiguration.metadataStyle ?? self.styleConfiguration.baseStyle) +
                    "]".consoleText(self.styleConfiguration.baseStyle)
        }
        
        // Render the source file and line if currently visible.
        if self.outputConfiguration.sourceFileLineDisplayLogLevel.map({ $0 >= self.logLevel }) ?? false {
            // TODO: When possible to do so safely, use `source` instead of hacking up `file`.
            text += " (".consoleText(self.styleConfiguration.baseStyle) +
                    "\(self.conciseSourcePath(file))".consoleText(self.styleConfiguration.fileStyle ?? self.styleConfiguration.baseStyle) +
                    ":".consoleText(self.styleConfiguration.baseStyle) +
                    "\(line.description)".consoleText(self.styleConfiguration.lineStyle ?? self.styleConfiguration.baseStyle) +
                    ")".consoleText(self.styleConfiguration.baseStyle)
        }

        self.console.output(text)
    }

    /// splits a path on the /Sources/ folder, returning everything after
    ///
    ///     "/Users/developer/dev/MyApp/Sources/Run/main.swift"
    ///     // becomes
    ///     "Run/main.swift"
    ///
    private func conciseSourcePath(_ path: String) -> String {
        let separator: Substring = path.contains("Sources") ? "Sources" : "Tests"
        return path.split(separator: "/")
            .split(separator: separator)
            .last?
            .joined(separator: "/") ?? path
    }
}

private extension LogHandler {
    /// Merge the metadata provided as "one-off" values for a single log message with the `LogHandler`'s "persistent"
    /// metadata, according to the following rules:
    ///
    /// - If no message-specific metadata was provided at all (a `nil` input), the result is identical to an empty
    ///   input (i.e. `[:]`).
    ///
    /// - If a message-specific metadata key conflicts with a persistent metadata key, only the message-specific value
    ///   appears in the result.
    ///
    /// - If both the message-specific metadata and the persistent metadata are empty or missing (i.e. if the result
    ///   would be empty), `nil` is returned in lieu of an empty dictionary.
    ///
    /// Typical usage:
    ///
    ///     if let allMetadata = self.mergeMetadata(with: messageMetadata) {
    ///         // include the metadata in the log message
    ///     }
    func mergeMetadata(with oneOffMetadata: Logger.Metadata?) -> Logger.Metadata? {
        if let oneOffMetadata = oneOffMetadata, !oneOffMetadata.isEmpty {
            guard !self.metadata.isEmpty else { return oneOffMetadata }
            return self.metadata.merging(oneOffMetadata) { $1 }
        } else {
            return self.metadata.isEmpty ? nil : self.metadata
        }
    }
}

extension LoggingSystem {
    /// Bootstraps a `ConsoleLogger` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    ///     LoggingSystem.boostrap(console: console)
    ///
    /// - Parameters:
    ///   - console: The console the logger will log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    ///   - outputConfiguration: The default output configuration to use by default for all loggers. This defaults to
    ///     the `.default` configuration.
    ///   - styleConfiguration: The default style configuration to use by default for all loggers. This defaults to the
    ///     `.default` configuration.
    public static func bootstrap(
        console: Console,
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        outputConfiguration: Logger.OutputConfiguration = .default,
        styleConfiguration: Logger.StyleConfiguration = .default
    ) {
        self.bootstrap { label in
            return ConsoleLogger(label: label, console: console, level: level, metadata: metadata, settings: outputConfiguration, style: styleConfiguration)
        }
    }
}

private extension Logger.OutputConfiguration.TimestampLoggingFormat {

    static let cachedISODateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }()

    func render(at date: Date) -> String {
        switch self {
            case .highPrecisionISO8601:
                return Self.cachedISODateFormatter.string(from: date)
            case .minimal:
                /// - TODO: Implement. For now just use the ISO 8601 format
                return Self.cachedISODateFormatter.string(from: date)
            case .custom(let callback):
                return callback(date)
        }
    }
}

public import Logging

#if ConfigReader
public import Configuration
#endif

/// Outputs logs to console via a ``LoggerFragment`` pipeline.
public struct ConsoleLogger<T: LoggerFragment>: LogHandler, Sendable {
    /// The log handler's label.
    public let label: String

    // See `LogHandler.metadata`.
    public var metadata: Logger.Metadata

    // See `LogHandler.metadataProvider`.
    public var metadataProvider: Logger.MetadataProvider?

    // See `LogHandler.logLevel`.
    public var logLevel: Logger.Level

    /// The ``LoggerFragment`` this logger outputs through.
    public var fragment: T

    /// The printer used to output log messages. Used for testing purposes only.
    private let printer: any ConsoleLoggerPrinter

    /// Creates a new ``ConsoleLogger`` instance.
    ///
    /// - Parameters:
    ///   - fragment: The ``LoggerFragment`` this logger outputs through.
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - label: Unique identifier for this logger.
    ///   - level: The minimum level of message that the logger will output. Defaults to `.debug`.
    ///   - metadata: Extra metadata to log with the message. Defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to use for this logger. Defaults to `nil`.
    public init(
        fragment: T = .default,
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        label: String,
        level: Logger.Level = .debug,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.fragment = fragment
        self.printer = printer
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.metadataProvider = metadataProvider
    }

    /// Creates a new ``ConsoleLogger`` instance.
    ///
    /// - Parameters:
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - label: Unique identifier for this logger.
    ///   - level: The minimum level of message that the logger will output. Defaults to `.debug`.
    ///   - metadata: Extra metadata to log with the message. Defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to use for this logger. Defaults to `nil`.
    ///   - fragment: The ``LoggerFragment`` this logger outputs through.
    public init(
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        label: String,
        level: Logger.Level = .debug,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> T
    ) {
        self.fragment = fragment()
        self.printer = printer
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.metadataProvider = metadataProvider
    }

    #if ConfigReader
    /// Creates a new ``ConsoleLogger`` instance.
    ///
    /// ## Configuration keys
    /// - `log.level` (string, optional, default: `"debug"`): The minimum level of message that the logger will output.
    ///
    /// - Parameters:
    ///   - fragment: The ``LoggerFragment`` this logger outputs through.
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - label: Unique identifier for this logger.
    ///   - config: The config reader to read the log level from. Defaults to `.debug`.
    ///   - metadata: Extra metadata to log with the message. Defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to use for this logger. Defaults to `nil`.
    public init(
        fragment: T = .default,
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        label: String,
        config: ConfigReader,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.fragment = fragment
        self.printer = printer
        self.label = label
        self.metadata = metadata
        self.logLevel = config.string(forKey: "log.level", as: Logger.Level.self, default: .debug)
        self.metadataProvider = metadataProvider
    }

    /// Creates a new ``ConsoleLogger`` instance.
    ///
    /// ## Configuration keys
    /// - `log.level` (string, optional, default: `"debug"`): The minimum level of message that the logger will output.
    ///
    /// - Parameters:
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - label: Unique identifier for this logger.
    ///   - config: The config reader to read the log level from. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to use for this logger. This defaults to `nil`.
    ///   - fragment: The ``LoggerFragment`` this logger outputs through.
    public init(
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        label: String,
        config: ConfigReader,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> T
    ) {
        self.fragment = fragment()
        self.printer = printer
        self.label = label
        self.metadata = metadata
        self.logLevel = config.string(forKey: "log.level", as: Logger.Level.self, default: .debug)
        self.metadataProvider = metadataProvider
    }
    #endif

    // See `LogHandler.subscript(metadataKey:)`.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { self.metadata[key] }
        set { self.metadata[key] = newValue }
    }

    // See `LogHandler.log(event:)`.
    public func log(event: LogEvent) {
        var output = FragmentOutput()
        var record = LogRecord(
            level: event.level,
            message: event.message,
            metadata: event.metadata,
            source: event.source,
            file: event.file,
            function: event.function,
            line: event.line,
            label: self.label,
            loggerLevel: self.logLevel,
            loggerMetadata: self.metadata,
            metadataProvider: self.metadataProvider
        )

        self.fragment.write(&record, to: &output)
        self.printer.print(output.text)
    }
}

extension Logger.Level {
    /// Converts log level to console style
    var style: ANSIColor? {
        switch self {
        case .trace, .debug: nil
        case .info, .notice: .cyan
        case .warning: .yellow
        case .error: .red
        case .critical: .brightRed
        }
    }
}

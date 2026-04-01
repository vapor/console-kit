import Logging

/// The complete explicit type of the ``defaultLoggerFragment()``. Unfortunately, we have to
/// spell it out instead of just letting it be `some LoggerFragment` in order to define the
/// ``ConsoleLogger`` alias properly.
public typealias DefaultLoggerFragmentType = AndFragment<AndFragment<AndFragment<IfMaxLevelFragment<LabelFragment>, AndFragment<SeparatorFragment<LevelFragment>, SeparatorFragment<MessageFragment>>>, SeparatorFragment<MetadataFragment>>, IfMaxLevelFragment<SeparatorFragment<SourceLocationFragment>>>

/// A ``LoggerFragment`` which implements the default logger message format.
public func defaultLoggerFragment() -> DefaultLoggerFragmentType {
    LabelFragment().maxLevel(.trace)
        .and(LevelFragment().separated(" ").and(MessageFragment().separated(" ")))
        .and(MetadataFragment().separated(" "))
        .and(SourceLocationFragment().separated(" ").maxLevel(.debug))
}

/// A ``LoggerFragment`` which implements the default logger message format with a timestamp at the front.
public func timestampDefaultLoggerFragment(
    timestampSource: some TimestampSource = SystemTimestampSource()
) -> some LoggerFragment {
    TimestampFragment(timestampSource).and(defaultLoggerFragment().separated(" "))
}

/// Outputs logs to a ``Console`` via a ``LoggerFragment`` pipeline.
public struct ConsoleFragmentLogger<T: LoggerFragment>: LogHandler, Sendable {
    /// The log handler's label.
    public let label: String

    // See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    // See `LogHandler.metadataProvider`.
    public var metadataProvider: Logger.MetadataProvider?
    
    // See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    
    /// The console to which messages will be logged.
    public let console: any Console
    
    private var _fragment: T

    /// The ``LoggerFragment`` this logger outputs through.
    public var fragment: T {
        get { self._fragment }
        @available(*, deprecated, message: "Setting ConsoleFragmentLogger's fragment after creation is deprecated.")
        set { self._fragment = newValue }
    }

    /// Creates a new ``ConsoleFragmentLogger`` instance.
    ///
    /// - Parameters:
    ///   - fragment: The ``LoggerFragment`` this handler outputs through.
    ///   - label: Unique identifier for this handler.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the handler will output. Defaults to `.debug`.
    ///   - metadata: Extra metadata to log with the message. Defaults to an empty dictionary.
    public init(fragment: T = defaultLoggerFragment(), label: String, console: any Console, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
        self._fragment = fragment
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
    }
    
    /// Creates a new ``ConsoleFragmentLogger`` instance.
    ///
    /// - Parameters:
    ///   - fragment: The ``LoggerFragment`` this handler outputs through.
    ///   - label: Unique identifier for this handler.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the handler will output. Defaults to `.debug`.
    ///   - metadata: Extra metadata to log with the message. Defaults to an empty dictionary.
    ///   - metadataProvider: A metadata provider to associate with this handler.
    public init(fragment: T = defaultLoggerFragment(), label: String, console: any Console, level: Logger.Level = .debug, metadata: Logger.Metadata = [:], metadataProvider: Logger.MetadataProvider?) {
        self._fragment = fragment
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
        self.metadataProvider = metadataProvider
    }
    
    // See `LogHandler.subscript(metadataKey:)`.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
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
        self.console.output(output.text)
    }
}

/// Outputs logs to a ``Console`` using the ``defaultLoggerFragment()``.
public typealias ConsoleLogger = ConsoleFragmentLogger<DefaultLoggerFragmentType>

extension LoggingSystem {
    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem` as the default log handler.
    ///
    /// ```swift
    /// LoggingSystem.boostrap(console: console)
    /// ```
    ///
    /// - Parameters:
    ///   - console: The console the logger will log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    public static func bootstrap(
        console: any Console,
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:]
    ) {
        self.bootstrap(console: console, level: level, metadata: metadata, metadataProvider: nil)
    }
    
    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem` as the default log handler.
    ///
    /// ```swift
    /// LoggingSystem.boostrap(console: console)
    /// ```
    ///
    /// - Parameters:
    ///   - console: The console the logger will log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        console: any Console,
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.bootstrap({ label, metadataProvider in
            return ConsoleLogger(label: label, console: console, level: level, metadata: metadata, metadataProvider: metadataProvider)
        }, metadataProvider: metadataProvider)
    }
    
    /// Bootstraps a ``ConsoleFragmentLogger`` to the `LoggingSystem` as the default log handler.
    ///
    /// ```swift
    /// LoggingSystem.boostrap(fragment: timestampDefaultLoggerFragment())
    /// ```
    ///
    /// - Parameters:
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    ///   - console: The console the logger will log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        fragment: some LoggerFragment,
        console: any Console,
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.bootstrap({ label, metadataProvider in
            ConsoleFragmentLogger(fragment: fragment, label: label, console: console, level: level, metadata: metadata, metadataProvider: metadataProvider)
        }, metadataProvider: metadataProvider)
    }
}

extension Logger.Level {
    /// Converts log level to console style
    public var style: ConsoleStyle {
        switch self {
        case .trace, .debug: return .plain
        case .info, .notice: return .info
        case .warning: return .warning
        case .error: return .error
        case .critical: return ConsoleStyle(color: .brightRed)
        }
    }

    @available(*, deprecated, renamed: "rawValue", message: "Use `Logger.Level.rawValue` instead")
    public var name: String {
        self.rawValue.uppercased()
    }
}

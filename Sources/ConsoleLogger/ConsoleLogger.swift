public import Logging

/// Outputs logs to console via a ``LoggerFragment`` pipeline.
public struct ConsoleLogger<T: LoggerFragment>: LogHandler, Sendable {
    public let label: String

    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata

    /// See `LogHandler.metadataProvider`.
    public var metadataProvider: Logger.MetadataProvider?

    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level

    /// The ``LoggerFragment`` this logger outputs through.
    public var fragment: T

    /// Creates a new ``ConsoleLogger`` instance.
    ///
    /// - Parameters:
    ///   - fragment: The ``LoggerFragment`` this logger outputs through.
    ///   - label: Unique identifier for this logger.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to use for this logger. This defaults to `nil`.
    public init(
        fragment: T = .default,
        label: String,
        level: Logger.Level = .debug,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.fragment = fragment
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.metadataProvider = metadataProvider
    }

    /// Creates a new ``ConsoleLogger`` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to use for this logger. This defaults to `nil`.
    ///   - fragment: The ``LoggerFragment`` this logger outputs through.
    public init(
        label: String,
        level: Logger.Level = .debug,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> T
    ) {
        self.fragment = fragment()
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.metadataProvider = metadataProvider
    }

    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { self.metadata[key] }
        set { self.metadata[key] = newValue }
    }

    /// See `LogHandler.log(level:message:metadata:source:file:function:line:)`.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        var output = FragmentOutput()
        var record = LogRecord(
            level: level,
            message: message,
            metadata: metadata,
            source: source,
            file: file,
            function: function,
            line: line,
            label: self.label,
            loggerLevel: self.logLevel,
            loggerMetadata: self.metadata,
            metadataProvider: self.metadataProvider
        )

        self.fragment.write(&record, to: &output)
        print(output.text)
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

    public var name: String {
        "\(self)".uppercased()
    }
}

import Logging

/// A `LoggerFragment` which implements the default logger message format.
public func defaultLoggerFragment() -> some LoggerFragment {
	TimestampFragment().and(LabelFragment().separated(" ")).maxLevel(.trace)
		.and(LevelFragment().separated(" ").and(MessageFragment().separated(" ")))
		.and(MetadataFragment().separated(" "))
		.and(SourceLocationFragment().separated(" ").maxLevel(.debug))
}

/// Outputs logs to a `Console` via a `LoggerFragment` pipeline.
public struct ConsoleFragmentLogger<T: LoggerFragment>: LogHandler, Sendable {
	public let label: String
	
	/// See `LogHandler.metadata`.
	public var metadata: Logger.Metadata
	
	/// See `LogHandler.metadataProvider`.
	public var metadataProvider: Logger.MetadataProvider?
	
	/// See `LogHandler.logLevel`.
	public var logLevel: Logger.Level
	
	/// The conosle that the messages will get logged to.
	public let console: Console & Sendable
	
	/// The `LoggerFragment` this logger outputs through.
	public var fragment: T
	
	/// Creates a new `ConsoleLogger` instance.
	///
	/// - Parameters:
	///   - fragment: The `LoggerFragment` this logger outputs through.
	///   - label: Unique identifier for this logger.
	///   - console: The console to log the messages to.
	///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
	///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
	public init(fragment: T, label: String, console: Console & Sendable, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
		self.fragment = fragment
		self.label = label
		self.metadata = metadata
		self.logLevel = level
		self.console = console
	}
	
	public init(fragment: T, label: String, console: Console & Sendable, level: Logger.Level = .debug, metadata: Logger.Metadata = [:], metadataProvider: Logger.MetadataProvider?) {
		self.fragment = fragment
		self.label = label
		self.metadata = metadata
		self.logLevel = level
		self.console = console
		self.metadataProvider = metadataProvider
	}
	
	/// See `LogHandler[metadataKey:]`.
	///
	/// This just acts as a getter/setter for the `.metadata` property.
	public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
		get { return self.metadata[key] }
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

		self.console.output(output.text)
	}
}

/// Outputs logs to a `Console`.
public struct ConsoleLogger: LogHandler, Sendable {
    public let label: String
    
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// See `LogHandler.metadataProvider`.
    public var metadataProvider: Logger.MetadataProvider?
    
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    
    /// The conosle that the messages will get logged to.
    public let console: Console & Sendable
	
	public var fragment: some LoggerFragment = defaultLoggerFragment()
	
#if CI // satisfy the easily-confused API breakage checker
	public func log(
		level: Logger.Level,
		message: Logger.Message,
		metadata: Logger.Metadata?,
		file: String,
		function: String,
		line: UInt
	) {
		self.log(level: level, message: message, metadata: metadata, source: file.prefix(while: { $0 != "/"  }), file: file, function: function, line: line)
	}
#endif
	
    /// Creates a new `ConsoleLogger` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    public init(label: String, console: Console & Sendable, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
    }
    
    public init(label: String, console: Console & Sendable, level: Logger.Level = .debug, metadata: Logger.Metadata = [:], metadataProvider: Logger.MetadataProvider?) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
        self.metadataProvider = metadataProvider
    }
    
    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
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

		self.console.output(output.text)
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
    public static func bootstrap(console: Console & Sendable, level: Logger.Level = .info, metadata: Logger.Metadata = [:]) {
        self.bootstrap { label in
            return ConsoleLogger(label: label, console: console, level: level, metadata: metadata)
        }
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
    
    public var name: String {
        switch self {
        case .trace: return "TRACE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .notice: return "NOTICE"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
}

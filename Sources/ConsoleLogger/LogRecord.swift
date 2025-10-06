public import Logging

/// Information about a specific log message, including information from the logger the message was logged to.
public struct LogRecord {
    public init(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata? = nil,
        source: String,
        file: String,
        function: String,
        line: UInt,
        label: String,
        loggerLevel: Logger.Level,
        loggerMetadata: Logger.Metadata,
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.level = level
        self.message = message
        self.metadata = metadata
        self.source = source
        self.file = file
        self.function = function
        self.line = line
        self.label = label
        self.loggerLevel = loggerLevel
        self.loggerMetadata = loggerMetadata
        self.metadataProvider = metadataProvider
    }

    /// The log level of the message
    public var level: Logger.Level
    /// The logged message
    public var message: Logger.Message
    /// The metadata explicitly associated with the logged message
    public var metadata: Logger.Metadata?
    /// The source of the log message, usually the module name
    public var source: String
    /// The file the message was logged from
    public var file: String
    /// The function the message was logged from
    public var function: String
    /// The line number in the file the message was logged from
    public var line: UInt

    /// The label of the logger the message was logged to
    public var label: String
    /// The log level of the logger the message was logged to
    public var loggerLevel: Logger.Level
    /// The metadata associated with the logger the message was logged to
    public var loggerMetadata: Logger.Metadata
    /// The metadata provider associated with the logger the message was logged to
    public var metadataProvider: Logger.MetadataProvider?

    /// Combine all of the metadata into a single set.
    public mutating func allMetadata() -> [String: Logger.MetadataValue] {
        // We aren't mutating self here currently,
        // but keeping the method marked that way will ensure we can cache the result
        // without breaking the public API if we decide that's desirable.
        self.loggerMetadata
            .merging(self.metadataProvider?.get() ?? [:]) { $1 }
            .merging(self.metadata ?? [:]) { $1 }
    }
}

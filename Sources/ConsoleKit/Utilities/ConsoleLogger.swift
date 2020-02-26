import Logging

/// Outputs logs to a `Console`.
public struct ConsoleLogger: LogHandler {
    public let label: String
    
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    
    /// The conosle that the messages will get logged to.
    public let console: Console
    
    /// Creates a new `ConsoleLogger` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    public init(label: String, console: Console, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
    }
    
    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
        set { self.metadata[key] = newValue }
    }
    
    /// See `LogHandler.log(level:message:metadata:file:function:line:)`.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        var text: ConsoleText = ""
        
        if self.logLevel <= .trace {
            text += "[ \(self.label) ] ".consoleText()
        }
            
        text += "[ \(level.name) ]".consoleText(level.style)
            + " "
            + message.description.consoleText()
        
        // only log metadata + file info if we are debug or trace
        if self.logLevel <= .debug {
            if !self.metadata.isEmpty {
                // only log metadata if not empty
                text += " " + self.metadata.descriptionWithoutQuotes.consoleText()
            }
            // log the concise path + line
            let fileInfo = self.conciseSourcePath(file) + ":" + line.description
            text += " (" + fileInfo.consoleText() + ")"
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
        return path.split(separator: "/")
            .split(separator: "Sources")
            .last?
            .joined(separator: "/") ?? path
    }
}

private extension Logger.Metadata {
    struct StringWithoutQuotes: CustomStringConvertible, Hashable {
        let description: String
    }

    var descriptionWithoutQuotes: String {
        var info: [StringWithoutQuotes: StringWithoutQuotes] = [:]
        for (key, value) in self {
            info[.init(description: key.description)] = .init(description: value.description)
        }
        return info.description
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
    public static func bootstrap(console: Console, level: Logger.Level = .info, metadata: Logger.Metadata = [:]) {
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

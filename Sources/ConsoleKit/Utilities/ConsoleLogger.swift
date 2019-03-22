import Logging

/// Outputs logs to a `Console`.
public struct ConsoleLogger: LogHandler {
    
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    
    /// The conosle that the messages will get logged to.
    public let console: Console
    
    /// Creates a new `ConsoleLogger` instance.
    ///
    /// - Parameters:
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    public init(console: Console, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
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
        let text: ConsoleText =
            "[ \(level.name) ]".consoleText(level.style) +
            " " +
            message.description.consoleText() +
            " " +
            "(\(file):\(line))".consoleText(.info)
        
        console.output(text)
    }
}

extension Logger.Level {
    /// Converts log level to console style
    fileprivate var style: ConsoleStyle {
        switch self {
        case .debug: return .plain
        case .info, .notice: return .info
        case .warning: return .warning
        case .error, .critical: return .error
        case .alert, .emergency: return ConsoleStyle(color: .brightRed)
        }
    }
    
    fileprivate var name: String {
        switch self {
        case .debug: return "Debug"
        case .info: return "Info"
        case .notice: return "Notice"
        case .warning: return "Warning"
        case .error: return "Error"
        case .critical: return "Critical"
        case .alert: return "Alert"
        case .emergency: return "Emergency"
        }
    }
}

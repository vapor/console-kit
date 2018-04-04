import Logging

/// Outputs logs to a `Console`.
public final class ConsoleLogger: Logger {
    /// The `Console` logs will be outputted to.
    public let console: Console

    /// Create a new `ConsoleLogger`.
    public init(console: Console) {
        self.console = console
    }

    /// See `Logger`.
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        let text: ConsoleText = ""
            + "[ \(level) ]".consoleText(level.style)
            + " "
            + string.consoleText()
            + " "
            + "(\(file):\(line))".consoleText(.info)
        console.output(text)
    }
}

extension LogLevel {
    /// Converts log level to console style
    fileprivate var style: ConsoleStyle {
        switch self {
        case .custom, .verbose, .debug: return .plain
        case .error, .fatal: return .error
        case .info: return .info
        case .warning: return .warning
        }
    }
}

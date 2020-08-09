import Logging

extension Logger.Level {
    /// Converts log level to console style
    ///
    /// - Warning: This property is deprecated. It remains here for backward compatibility only.
    @available(*, deprecated, message: "Use `Logger.styleConfiguration` instead.")
    public var style: ConsoleStyle {
        switch self {
        case .trace, .debug: return .plain
        case .info, .notice: return .info
        case .warning: return .warning
        case .error: return .error
        case .critical: return ConsoleStyle(color: .brightRed)
        }
    }
    
    /// Converts log level to a string for console output
    ///
    /// - Warning: This property is deprecated. It remains here for backward compatibility only.
    @available(*, deprecated, message: "Use `Logger.outputConfiguration` instead.")
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

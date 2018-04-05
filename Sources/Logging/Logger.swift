/// Capable of logging messages.
///
///     logger.info("This is an informational log")
///
/// The above code yields:
///
///     [ INFO ] This is an informational log (/path/to/file.swift:42)
///
public protocol Logger {
    /// Logs an encodable at the provided log level The encodable can be encoded to the required format.
    /// The log level indicates the type of log and/or severity
    ///
    /// Normally, you will use one of the convenience methods (i.e., `verbose(...)`, `info(...)`).
    func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt)
}

extension Logger {
    /// Verbose logs are used to log tiny, usually irrelevant information.
    /// They are helpful when tracing specific lines of code and their results
    public func verbose(_ string: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column) {
        self.log(string, at: .verbose, file: file, function: function, line: line, column: column)
    }
    
    /// Debug logs are used to debug problems
    public func debug(_ string: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column) {
        self.log(string, at: .debug, file: file, function: function, line: line, column: column)
    }
    
    /// Info logs are used to indicate a specific infrequent event occurring.
    public func info(_ string: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column) {
        self.log(string, at: .info, file: file, function: function, line: line, column: column)
    }
    
    /// Warnings are used to indicate something should be fixed but may not have to be solved yet
    public func warning(_ string: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column) {
        self.log(string, at: .warning, file: file, function: function, line: line, column: column)
    }
    
    /// Error, indicates something went wrong and a part of the execution was failed.
    public func error(_ string: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column) {
        self.log(string, at: .error, file: file, function: function, line: line, column: column)
    }
    
    /// Fatal errors/crashes, execution should/must be cancelled.
    public func fatal(_ string: String, file: String = #file, function: String = #function, line: UInt = #line, column: UInt = #column) {
        self.log(string, at: .fatal, file: file, function: function, line: line, column: column)
    }
}

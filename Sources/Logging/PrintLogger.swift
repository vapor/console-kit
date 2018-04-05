/// Simply prints the supplied logs to `Swift.print`.
public final class PrintLogger: Logger {
    /// Create a new `PrintLogger`.
    public init() { }

    /// See `Logger`.
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        Swift.print("[\(level)] \(string) (\(file):\(function):\(line):\(column))")
    }
}

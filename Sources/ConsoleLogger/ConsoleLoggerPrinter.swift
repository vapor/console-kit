/// Defines a printer used by a ``ConsoleLogger`` to output log messages.
public protocol ConsoleLoggerPrinter: Sendable {
    /// The method called by a ``ConsoleLogger`` to print a log message.
    ///
    /// - Parameter string: The string to print.
    func print(_ string: String)
}

/// The default ``ConsoleLoggerPrinter`` that prints to standard output.
public struct DefaultConsoleLoggerPrinter: ConsoleLoggerPrinter {
    /// Prints the given string to standard output using ``Swift/print(_:separator:terminator:)``.
    ///
    /// - Parameter string: The string to print.
    public func print(_ string: String) {
        Swift.print(string)
    }

    /// Creates a new ``DefaultConsoleLoggerPrinter``.
    public init() {}
}

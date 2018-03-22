import Dispatch
import Foundation

/// Simply prints the supplied logs to Swift.print
public final class PrintLogger: Logger {
    /// Internal queue for synchronizing log output.
    private let queue: DispatchQueue

    /// Create a new print logger
    public init() {
        queue = .init(label: "codes.vapor.console.logging.print-logger.sync")
    }

    /// See logger.log
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        queue.async {
            Swift.print("[\(level)] \(string) (\(file):\(function):\(line):\(column))")
        }
    }
}

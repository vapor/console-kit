import Debugging

/// Errors working with the `Command` module.
public struct CommandError: Debuggable {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String

    /// See `Debuggable`.
    public var sourceLocation: SourceLocation

    /// See `Debuggable`.
    public var stackTrace: [String]

    /// Creates a new `CommandError`
    internal init(identifier: String, reason: String, source: SourceLocation) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = CommandError.makeStackTrace()
    }
}

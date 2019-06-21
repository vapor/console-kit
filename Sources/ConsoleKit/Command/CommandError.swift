/// Errors working with the `Command` module.
public struct CommandError: Error, CustomStringConvertible {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String

    /// See `CustomStringConvertible`.
    public var description: String {
        return "\(self.identifier): \(self.reason)"
    }

    /// Creates a new `CommandError`
    internal init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

/// Errors working with the `Command` module.
public struct CommandError: Error {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String

    /// Creates a new `CommandError`
    internal init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

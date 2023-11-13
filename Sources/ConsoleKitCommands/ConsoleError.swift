/// Errors working with the `Console` module.
public struct ConsoleError: Error {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String

    /// Creates a new `ConsoleError`
    internal init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

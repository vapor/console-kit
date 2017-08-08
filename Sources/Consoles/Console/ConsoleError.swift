/// Consoles should only throw these errors
public struct ConsoleError: Error {
    public let reason: String
    public init(reason: String) {
        self.reason = reason
    }
}

/// A single piece of `ConsoleText`. Contains a raw `String` and the desired `ConsoleStyle`.
public struct ConsoleTextFragment: Sendable {
    /// The raw `String`.
    public var string: String

    /// `ConsoleStyle` to use when displaying the `string`.
    public var style: ConsoleStyle

    /// Creates a new `ConsoleTextFragment`.
    public init(string: String, style: ConsoleStyle = .plain) {
        self.string = string
        self.style = style
    }
}

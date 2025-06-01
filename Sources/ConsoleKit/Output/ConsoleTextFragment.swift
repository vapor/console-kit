/// A single piece of ``ConsoleText``. Contains a raw `String` and the desired ``ConsoleStyle``.
public struct ConsoleTextFragment: Sendable {
    /// The raw `String`.
    public var string: String

    /// ``ConsoleStyle`` to use when displaying the `string`.
    public var style: ConsoleStyle

    /// Creates a new ``ConsoleTextFragment``.
    public init(string: String, style: ConsoleStyle = .plain) {
        self.string = string
        self.style = style
    }
}

extension ConsoleTextFragment: CustomStringConvertible {
    /// See `CustomStringConvertible`.
    public var description: String {
        return self.string
    }
}

extension ConsoleTextFragment: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(string: value)
    }
}

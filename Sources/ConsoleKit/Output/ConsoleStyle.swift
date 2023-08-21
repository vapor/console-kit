/// Representation of a style for outputting to a Console in different colors with differing attributes.
/// A few suggested default styles are provided.
public struct ConsoleStyle: Sendable {
    /// Optional text color. If `nil`, text is plain.
    public let color: ConsoleColor?

    /// Optional background color. If `nil` background is plain.
    public let background: ConsoleColor?

    /// If `true`, text is bold.
    public let isBold: Bool

    /// Creates a new `ConsoleStyle`.
    public init(color: ConsoleColor? = nil, background: ConsoleColor? = nil, isBold: Bool = false) {
        self.color = color
        self.background = background
        self.isBold = isBold
    }

    /// Plain text with no color or background.
    public static var plain: ConsoleStyle { return .init(color: nil) }

    /// Green text with no background.
    public static var success: ConsoleStyle { return .init(color: .green) }

    /// Light blue text with no background.
    public static var info: ConsoleStyle { return .init(color: .cyan) }

    /// Yellow text with no background.
    public static var warning: ConsoleStyle { return .init(color: .yellow) }

    /// Red text with no background.
    public static var error: ConsoleStyle { return .init(color: .red) }
}

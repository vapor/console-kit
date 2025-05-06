/// Supported colors for creating a `ConsoleStyle` for `ConsoleText`.
///
/// - note: Normal and bright colors are represented here separately instead of as a flag on `ConsoleStyle`
///         basically because "that's how ANSI colors work". It's a little conceptually weird, but so are terminal
///         control codes.
///
public enum ConsoleColor: Sendable {
    // MARK: Normal

    /// Black
    case black
    /// Red
    case red
    /// Green
    case green
    /// Yellow
    case yellow
    /// Blue
    case blue
    /// Magenta
    case magenta
    /// Cyan
    case cyan
    /// White
    case white

    // MARK: Bright

    /// Bright black
    case brightBlack
    /// Bright red
    case brightRed
    /// Bright green
    case brightGreen
    /// Bright yellow
    case brightYellow
    /// Bright blue
    case brightBlue
    /// Bright magenta
    case brightMagenta
    /// Bright cyan
    case brightCyan
    /// Bright white
    case brightWhite

    // MARK: Custom
    
    /// A color from the predefined 256-color palette
    case palette(UInt8)
    
    /// A 24-bit "true" color
    case custom(r: UInt8, g: UInt8, b: UInt8)
}

#if canImport(Darwin)
import Darwin.C
#elseif canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Musl)
@preconcurrency import Musl
#elseif canImport(Android)
@preconcurrency import Android
#elseif os(WASI)
import WASILibc
#elseif os(Windows)
import CRT
#endif

/// Protocol for powering styled Console I/O.
///
/// ### Output
///
/// ``Console``s can output stylized text via the ``ConsoleText`` struct.
///
/// ```swift
/// console.output("Hello, " + "world!".consoleText(color: .green))
/// ```
///
/// > Tip: See ``ConsoleStyle`` for all available text style options.
///
/// There are also convenience methods for printing common styles.
///
/// ```swift
/// console.info("Here is some information")
/// ```
///
/// ### Input
///
/// ``Console``s can also request input from the user.
///
/// ```swift
/// let answer = console.ask("How are you doing?")
/// print(answer)
/// ```
///
/// ### Clear
///
/// ``Console``s can clear previously outputted content using ``Console/clear(_:)``.
///
/// ```swift
/// console.print("Hello!")
/// console.clear(.line) // delete hello
/// ```
///
/// See ``Console/pushEphemeral()`` method for clearing arbitrary chunks of output.
///
/// ### Other
///
/// Use the ``Console/report(error:newLine:)`` method for reporting errors to the ``Console``.
///
/// Get the ``Console``'s current size using the ``Console/size`` property.
///
public protocol Console: AnyObject, Sendable {
    /// The size of the ``Console`` window. Used for calculating lines printed and centering text.
    var size: (width: Int, height: Int) { get }

    /// Returns a `String` of input read from the ``Console`` until a line feed character was found.
    ///
    /// ```swift
    /// let input = console.input(isSecure: false)
    /// print(input) // String
    /// ```
    ///
    /// > note: The line feed character should not be included.
    ///
    /// - parameter isSecure: If `true`, the input should not be shown while it is entered.
    ///
    /// - returns: the string that was read, or an empty string if EOF was encountered
    func input(isSecure: Bool) -> String

    /// Outputs serialized ``ConsoleText`` to the ``Console``.
    ///
    /// ```swift
    /// console.output("Hello, " + "world!".consoleText(color: .green))
    /// ```
    ///
    /// - parameters:
    ///     - text: ``ConsoleText`` to serialize and print.
    ///     - newLine: If `true`, the next output will be on a new line.
    func output(_ text: ConsoleText, newLine: Bool)

    /// Clears previously printed ``Console`` output according to the ``ConsoleClear`` type given.
    ///
    /// - parameter type: ``ConsoleClear`` type to use, e.g., single line or whole screen.
    func clear(_ type: ConsoleClear)

    /// Outputs an error to the ``Console``'s error stream.
    ///
    /// > note: This is `stderr` for most consoles.
    ///
    /// - parameters:
    ///     - error: Error `String` to output.
    ///     - newLine: If `true`, the next error will be on a new line.
    func report(error: String, newLine: Bool)

    var userInfo: [AnySendableHashable: any Sendable] { get set }

    /// If the ``Console`` supports ANSI commands such as color and cursor movement.
    var supportsANSICommands: Bool { get }
}

extension Console {
    public var supportsANSICommands: Bool {
        #if Xcode
        // Xcode output does not support ANSI commands
        return false
        #else
        // If STDOUT is not an interactive terminal then omit ANSI commands
        return isatty(STDOUT_FILENO) > 0
        #endif
    }
}

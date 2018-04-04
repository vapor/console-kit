/// Protocol for powering styled Console I/O.
public protocol Console: Extendable {
    /// The size of the console window used for
    /// calculating lines printed and centering text.
    var size: (width: Int, height: Int) { get }

    /// Returns a String of input read from the
    /// console until a line feed character was found.
    ///
    /// The line feed character should not be included.
    ///
    /// If secure is true, the input should not be
    /// shown while it is entered.
    func input(isSecure: Bool) -> String

    /// Outputs a String in the given style to
    /// the console. If newLine is true, the next
    /// output will appear on a new line.
    func output(_ string: String, style: ConsoleStyle, newLine: Bool)

    /// Outputs an error
    func report(error: String, newLine: Bool)

    /// Clears previously printed Console outputs
    /// according to the clear type given.
    func clear(_ type: ConsoleClear)
}

extension Console {
    /// See InputConsole.input
    /// note: Defaults to non secure input.
    public func input() -> String {
        return input(isSecure: false)
    }

    /// See OutputConsole.output
    public func output(_ string: String, style: ConsoleStyle) {
        self.output(string, style: style, newLine: true)
    }
}


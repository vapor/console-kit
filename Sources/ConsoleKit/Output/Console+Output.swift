extension Console {
    /// Outputs serialized `ConsoleText` to the `Console`.
    ///
    ///     console.output("Hello, " + "world!".consoleText(color: .green))
    ///
    /// - parameters:
    ///     - output: `ConsoleText` to serialize and print.
    public func output(_ text: ConsoleText) {
        self.output(text, newLine: true)
    }

    /// Outputs a `String` to the `Console` with the specified `ConsoleStyle` style.
    ///
    ///     console.print("Hello, world!", style: .plain)
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - style: `ConsoleStyle` to use for the `string`.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool = true) {
        self.output(string.consoleText(style), newLine: newLine)
    }

    /// Outputs a `String` to the `Console` with `ConsoleStyle.plain` style.
    ///
    ///     console.print("Hello, world!")
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func print(_ string: String = "", newLine: Bool = true) {
        self.output(string.consoleText(.plain), newLine: newLine)
    }

    /// Outputs a `String` to the `Console` with `ConsoleStyle.info` style.
    ///
    ///     console.info("Vapor is the best.")
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func info(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.info), newLine: newLine)
    }

    /// Outputs a `String` to the `Console` with `ConsoleStyle.success` style.
    ///
    ///     console.success("It works!")
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func success(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.success), newLine: newLine)
    }

    /// Outputs a `String` to the `Console` with `ConsoleStyle.warning` style.
    ///
    ///     console.warning("Watch out...")
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func warning(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.warning), newLine: newLine)
    }

    /// Outputs a `String` to the `Console` with `ConsoleStyle.error` style.
    ///
    ///     console.error("Uh oh...")
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func error(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.error), newLine: newLine)
    }
}

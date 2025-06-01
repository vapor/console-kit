extension Console {
    /// Outputs serialized ``ConsoleText`` to the ``Console``.
    ///
    /// ```swift
    /// console.output("Hello, " + "world!".consoleText(color: .green))
    /// ```
    ///
    /// - parameter text: ``ConsoleText`` to serialize and print.
    public func output(_ text: ConsoleText) {
        self.output(text, newLine: true)
    }

    /// Outputs an array of serialized ``ConsoleText`` to the ``Console``.
    ///
    /// - Parameters
    ///   - texts: An array ``ConsoleText`` to serialize and print.
    ///   - newLine: If `true`, every element in the `texts` array will be printed on a new line.
    public func output(_ texts: [ConsoleText], newLine: Bool = true) {
        for text in texts {
            self.output(text, newLine: newLine)
        }
    }

    /// Outputs a `String` to the ``Console`` with the specified ``ConsoleStyle`` style.
    ///
    /// ```swift
    /// console.print("Hello, world!", style: .plain)
    /// ```
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - style: ``ConsoleStyle`` to use for the `string`.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool = true) {
        self.output(string.consoleText(style), newLine: newLine)
    }

    /// Outputs to the ``Console`` a combined ``ConsoleText`` from a `key` and `value`.
    ///
    /// ```swift
    /// console.output(key: "name", value: "Vapor")
    /// // name: Vapor
    /// ```
    ///
    /// - Parameters:
    ///   - key: `String` to use as the key, which will precede the `value` an a colon.
    ///   - value: `String` to use as the value.
    ///   - style: ``ConsoleStyle`` to use for printing the `value`.
    public func output(key: String, value: String, style: ConsoleStyle = .info) {
        self.output(key.consoleText() + ": " + value.consoleText(style))
    }

    /// Outputs a `String` to the ``Console`` with ``ConsoleStyle/plain`` style.
    ///
    /// ```swift
    /// console.print("Hello, world!")
    /// ```
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func print(_ string: String = "", newLine: Bool = true) {
        self.output(string.consoleText(.plain), newLine: newLine)
    }

    /// Outputs a `String` to the ``Console`` with ``ConsoleStyle/info`` style.
    ///
    /// ```swift
    /// console.info("Vapor is the best.")
    /// ```
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func info(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.info), newLine: newLine)
    }

    /// Outputs a `String` to the ``Console`` with ``ConsoleStyle/success`` style.
    ///
    /// ```swift
    /// console.success("It works!")
    /// ```
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func success(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.success), newLine: newLine)
    }

    /// Outputs a `String` to the ``Console`` with ``ConsoleStyle/warning`` style.
    ///
    /// ```swift
    /// console.warning("Watch out...")
    /// ```
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func warning(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.warning), newLine: newLine)
    }

    /// Outputs a `String` to the ``Console`` with ``ConsoleStyle/error`` style.
    ///
    /// ```swift
    /// console.error("Uh oh...")
    /// ```
    ///
    /// - parameters:
    ///     - string: `String` to print.
    ///     - newLine: If `true`, the next output will be on a new line.
    public func error(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.error), newLine: newLine)
    }
}

extension Console {
    /// See OutputConsole.output
    public func output(_ text: ConsoleText) {
        self.output(text, newLine: true)
    }
    
    /// See OutputConsole.output
    public func print(_ string: String = "", newLine: Bool = true) {
        self.output(string.consoleText(.plain), newLine: newLine)
    }

    /// Outputs a styled message to the console.
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool = false) {
        self.output(string.consoleText(style), newLine: newLine)
    }

    /// Outputs an informational message to the console.
    public func info(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.info), newLine: newLine)
    }

    /// Outputs a success message to the console.
    public func success(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.success), newLine: newLine)
    }

    /// Outputs a warning message to the console.
    public func warning(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.warning), newLine: newLine)
    }

    /// Outputs an error message to the console.
    public func error(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.error), newLine: newLine)
    }
}

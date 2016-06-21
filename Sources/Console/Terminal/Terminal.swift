public class Terminal: Console {
    /**
        Creates an instance of Terminal.
    */
    public init() { }

    /**
        Prints styled output to the terminal.
    */
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        let terminator = newLine ? "\n" : ""

        let output: String
        if let color = style.terminalColor {
            output = string.terminalColorize(color)
        } else {
            output = string
        }

        Swift.print(output, terminator: terminator)
    }

    /**
        Clears text from the terminal window.
    */
    public func clear(_ clear: ConsoleClear) {
        switch clear {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
    }

    /**
        Reads a line of input from the terminal.
    */
    public func input() -> String {
        return readLine(strippingNewline: true) ?? ""
    }

    /**
        Runs an ansi coded command.
    */
    private func command(_ command: Command) {
        output(command.ansi, newLine: false)
    }
}

public class Terminal: Console {
    /**
        Creates an instance of Terminal.
    */
    public init() { }

    public enum Command {
        case eraseScreen
        case eraseLine
        case cursorUp
    }

    /**
        Prints styled output to the terminal.
    */
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        let terminator = newLine ? "\n" : ""

        let output: String
        if let color = style.color {
            output = string.colorize(color.foreground)
        } else {
            output = string
        }

        Swift.print(output, terminator: terminator)
    }

    public func clear(_ clear: ConsoleClear) {
        switch clear {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
    }

    public func command(_ command: Command) {
        output(command.ansi, newLine: false)
    }

    /**
        Reads a line of input from the terminal.
    */
    public func input() -> String {
        return readLine(strippingNewline: true) ?? ""
    }
}

extension Terminal.Command {
    public var ansi: String {
        switch self {
        case .cursorUp:
            return "1A".ansi
        case .eraseScreen:
            return "2J".ansi
        case .eraseLine:
            return "2K".ansi
        }
    }
}

extension UInt8 {
    /**
        Formats a terminal code in ANSI.
    */
    private var ansi: String {
        return (self.description + "m").ansi
    }
}

extension String {
    private var ansi: String {
        return "\u{001B}[" + self
    }

    private static var eraseLine: String {
        return "2K".ansi
    }

    /**
        Wraps a string in a color.
    */
    private func colorize(_ color: UInt8) -> String {
        return color.ansi + self + UInt8(0).ansi
    }
}

extension ConsoleColor {
    /**
        Returns the foreground terminal color 
        code for the ConsoleColor.
    */
    private var foreground: UInt8 {
        switch self {
        case .black:
            return 30
        case .red:
            return 31
        case .green:
            return 32
        case .yellow:
            return 33
        case .blue:
            return 34
        case .magenta:
            return 35
        case .cyan:
            return 36
        case .white:
            return 37
        }
    }

    /**
        Returns the background terminal color
        code for the ConsoleColor.
    */
    private var background: UInt8 {
        switch self {
        case .black:
            return 40
        case .red:
            return 41
        case .green:
            return 42
        case .yellow:
            return 43
        case .blue:
            return 44
        case .magenta:
            return 45
        case .cyan:
            return 46
        case .white:
            return 47
        }
    }
}

extension ConsoleStyle {
    /**
        Returns the terminal console color
        for the ConsoleStyle.
    */
    private var color: ConsoleColor? {
        let color: ConsoleColor?

        switch self {
        case .plain:
            color = nil
        case .info:
            color = .cyan
        case .warning:
            color = .yellow
        case .error:
            color = .red
        case .success:
            color = .green
        case .custom(let c):
            color = c
        }

        return color
    }
}

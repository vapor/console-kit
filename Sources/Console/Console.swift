/**
    Protocol for powering styled Console I/O.
*/
public protocol Console {
    func output(_ string: String, style: ConsoleStyle, newLine: Bool)
    func input() -> String
    func clear(_ clear: ConsoleClear)
}

/**
    Different default console styles.
 
    Console implementations can choose which
    colors they use for the variouis styles.
*/
public enum ConsoleStyle {
    case plain
    case success
    case info
    case warning
    case error
    case custom(ConsoleColor)
}

/**
    Underlying colors for console styles.
*/
public enum ConsoleColor {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
}

public enum ConsoleClear {
    case screen
    case line
}

extension Console {
    /**
        Out method with plain default and newline.
    */
    public func output(_ string: String, style: ConsoleStyle = .plain, newLine: Bool = true) {
        output(string, style: style, newLine: newLine)
    }


    /**
        Outputs a plain message to the console.
    */
    public func print(_ string: String, newLine: Bool = true) {
        output(string, style: .plain, newLine: newLine)
    }

    /**
        Outputs an informational message to the console.
    */
    public func info(_ string: String, newLine: Bool = true) {
        output(string, style: .info, newLine: newLine)
    }

    /**
        Outputs a warning message to the console.
    */
    public func warning(_ string: String, newLine: Bool = true) {
        output(string, style: .warning, newLine: newLine)
    }

    /**
        Outputs an error message to the console.
    */
    public func error(_ string: String, newLine: Bool = true) {
        output(string, style: .error, newLine: newLine)

    }

    /**
        Requests input from the console
        after displaying the desired prompt.
    */
    public func ask(_ prompt: String, style: ConsoleStyle = .info) -> String {
        output(prompt, style: style)
        return input()
    }

    /**
        Requests yes/no confirmation from
        the console.
    */
    public func confirm(_ prompt: String, style: ConsoleStyle = .info) -> Bool {
        var i = 0
        var result = ""
        while result != "y" && result != "yes" && result != "n" && result != "no" {
            output(prompt, style: style)
            if i >= 1 {
                output("[y]es or [n]o: ", style: style, newLine: false)
            }
            result = input().lowercased()
            i += 1
        }

        return result == "y" || result == "yes"
    }
}

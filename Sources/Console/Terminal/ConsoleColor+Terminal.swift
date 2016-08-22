extension String {
    /**
        Wraps a string in the color indicated 
        by the UInt8 terminal color code.
    */
    func terminalColorize(_ color: ConsoleColor) -> String {
        return color.terminalForeground.ansi + self + UInt8(0).ansi
    }
}

extension ConsoleColor {
    /**
        Returns the foreground terminal color 
        code for the ConsoleColor.
    */
    var terminalForeground: UInt8 {
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
    var terminalBackground: UInt8 {
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

extension UInt8 {
    /**
        Converts a UInt8 to an ANSI code.
    */
    var ansi: String {
        return (self.description + "m").ansi
    }
}

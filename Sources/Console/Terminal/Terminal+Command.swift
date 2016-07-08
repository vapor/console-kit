extension Terminal {
    /**
        Available terminal commands.
    */
    enum Command {
        case eraseScreen
        case eraseLine
        case cursorUp
    }
}

extension Terminal.Command {
    /**
        Converts the command to its ansi code.
    */
    var ansi: String {
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

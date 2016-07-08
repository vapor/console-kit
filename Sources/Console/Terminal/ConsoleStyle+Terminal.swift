extension ConsoleStyle {
    /**
        Returns the terminal console color
        for the ConsoleStyle.
    */
    var terminalColor: ConsoleColor? {
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

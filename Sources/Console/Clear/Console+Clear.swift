extension Console {
    /// Clears n lines from the terminal.
    public func clear(lines: Int) throws {
        for _ in 0..<lines {
            clear(.line)
        }
    }
}


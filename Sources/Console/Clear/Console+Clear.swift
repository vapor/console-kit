extension Console {
    /// Deletes lines that were previously printed to the terminal.
    ///
    ///     console.print("Hello!")
    ///     console.clear(lines: 1) // clears the previous print
    ///
    /// - parameters:
    ///     - lines: The number of lines to clear.
    public func clear(lines: Int) {
        for _ in 0..<lines {
            clear(.line)
        }
    }
}


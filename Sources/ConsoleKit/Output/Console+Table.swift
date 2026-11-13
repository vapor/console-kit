extension Console {
    /// Outputs a formatted ASCII table to the console.
    ///
    /// The first row is treated as the header and is styled bold. Column widths
    /// are calculated automatically from the longest cell in each column.
    ///
    /// ```swift
    /// console.printTable([
    ///     ["Name", "Age"],
    ///     ["Alice", "30"],
    ///     ["Bob", "25"],
    /// ])
    /// ```
    ///
    /// - parameters:
    ///     - rows: Array of rows, where each row is an array of cell strings.
    ///     - style: ``ConsoleStyle`` to use for the table borders. `.plain` by default.
    public func printTable(_ rows: [[String]], style: ConsoleStyle = .plain) {
        guard !rows.isEmpty else { return }

        let columnCount = rows.map(\.count).max() ?? 0
        guard columnCount > 0 else { return }

        // Normalize all rows to the same column count
        let normalizedRows = rows.map { row -> [String] in
            var row = row
            row.append(contentsOf: Array(repeating: "", count: columnCount - row.count))
            return row
        }

        // Calculate column widths based on the longest cell in each column
        var columnWidths = Array(repeating: 0, count: columnCount)
        for row in normalizedRows {
            for (i, cell) in row.enumerated() {
                columnWidths[i] = max(columnWidths[i], cell.count)
            }
        }

        // Build border lines
        let topBorder = "┌" + columnWidths.map { String(repeating: "─", count: $0 + 2) }.joined(separator: "┬") + "┐"
        let headerSeparator = "├" + columnWidths.map { String(repeating: "─", count: $0 + 2) }.joined(separator: "┼") + "┤"
        let bottomBorder = "└" + columnWidths.map { String(repeating: "─", count: $0 + 2) }.joined(separator: "┴") + "┘"

        self.output(topBorder.consoleText(style))

        for (rowIndex, row) in normalizedRows.enumerated() {
            let cells: [ConsoleText] = row.enumerated().map { i, cell in
                let padding = String(repeating: " ", count: columnWidths[i] - cell.count)
                let padded = " " + cell + padding + " "
                if rowIndex == 0 {
                    return padded.consoleText(.init(isBold: true))
                }
                return padded.consoleText(style)
            }

            let styledLine: ConsoleText = cells.reduce("│".consoleText(style)) { $0 + $1 + "│".consoleText(style) }
            self.output(styledLine)

            if rowIndex == 0 {
                self.output(headerSeparator.consoleText(style))
            }
        }

        self.output(bottomBorder.consoleText(style))
    }
}

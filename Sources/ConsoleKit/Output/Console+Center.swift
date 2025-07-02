extension Console {
    /// Centers a `String` according to this console's `size`.
    ///
    /// - parameters:
    ///     - string: `String` to center.
    ///     - padding: `Character` to use for padding, `" "` by default.
    /// - returns: `String` with padding added so that it is centered.
    public func center(_ string: String, padding: Character = " ") -> String {
        // Split the string into lines
        let lines = string.split(separator: Character("\n")).map(String.init)
        return center(lines).joined(separator: "\n")
    }

    /// Centers an array of `String`s according to this console's `size`.
    ///
    /// - parameters:
    ///     - strings: `String` to center.
    ///     - padding: `Character` to use for padding, `" "` by default.
    /// - returns: `String` with padding added so that it is centered.
    public func center(_ strings: [String], padding: Character = " ") -> [String] {
        // Make sure there's more than one line
        guard !strings.isEmpty else {
            return []
        }

        var lines = strings

        // Find the longest line
        var longestLine = 0
        for line in lines {
            if line.count > longestLine {
                longestLine = line.count
            }
        }

        // Calculate the padding and make sure it's greater than or equal to 0
        let paddingCount = max(0, (size.width - longestLine) / 2)

        // Apply the padding to each line
        for i in 0..<lines.count {
            for _ in 0..<paddingCount {
                lines[i].insert(padding, at: lines[i].startIndex)
            }
        }

        return lines
    }

    /// Centers an array of ``ConsoleText`` according to this console's `size`.
    ///
    /// > Important: Each line to be centered must be a single ``ConsoleText`` object inside the array.
    ///
    /// - Parameters:
    ///   - texts: An array of ``ConsoleText``, each representing a line of text to be centered.
    ///   - padding: `Character` to use for padding, `" "` by default.
    ///
    /// - Returns: An array of ``ConsoleText`` with padding added so that each line is centered.
    public func center(_ texts: [ConsoleText], padding: Character = " ") -> [ConsoleText] {
        // Make sure there's more than one line
        guard !texts.isEmpty else {
            return []
        }

        var lines = texts

        // Find the longest line
        var longestLine = 0
        for line in lines {
            if line.description.count > longestLine {
                longestLine = line.description.count
            }
        }

        // Calculate the padding and make sure it's greater than or equal to 0
        let paddingCount = max(0, (size.width - longestLine) / 2)

        // Apply the padding to each line
        for i in 0..<lines.count {
            let diff = (longestLine - lines[i].description.count) / 2
            for _ in 0..<(paddingCount + diff) {
                lines[i].fragments.insert(.init(string: String(padding)), at: 0)
            }
        }

        return lines
    }
}

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
        var lines = strings

        // Make sure there's more than one line
        guard lines.count > 0 else {
            return []
        }

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
}

extension Array {
    /// Pops the first element from the array.
    mutating func popFirst() -> Element? {
        guard let pop = first else {
            return nil
        }
        self = Array(dropFirst())
        return pop
    }
}

extension Array where Element == String {
    var longestCount: Int {
        var count = 0

        for item in self {
            if item.count > count {
                count = item.count
            }
        }

        return count
    }
}

extension Console {
    func outputHelpListItem(name: String, help: String?, style: ConsoleStyle, padding: Int) {
        self.output(name.leftPad(to: padding - name.count).consoleText(style), newLine: false)
        if let help = help {
            for (index, line) in help.split(separator: "\n").map(String.init).enumerated() {
                if index == 0 {
                    self.print(line.leftPad(to: 1))
                } else {
                    self.print(line.leftPad(to: padding + 1))
                }
            }
        } else {
            self.print(" n/a")
        }
    }
}

private extension String {
    func leftPad(to padding: Int) -> String {
        return String(repeating: " ", count: padding) + self
    }
}

import protocol ConsoleKitTerminal.Console
import struct ConsoleKitTerminal.ConsoleStyle

extension Array {
    /// Pops the first element from the array.
    mutating func popFirst() -> Element? {
        self.isEmpty ? nil : self.removeFirst()
    }
}

extension Console {
    func outputHelpListItem(name: String, help: String?, style: ConsoleStyle, padding: Int) {
        self.output("\(" ".repeated(padding - name.count))\(name)".consoleText(style), newLine: false)
        if let lines = help?.split(separator: "\n"), !lines.isEmpty {
            self.print(" \(lines[0])")
            lines.dropFirst().forEach { self.print("\(" ".repeated(padding)) \($0)") }
        } else {
            self.print(" n/a")
        }
    }
}

private extension String {
    func repeated(_ count: Int) -> String { String(repeating: self, count: count) }
}

/// Errors working with the `Command` module.
public struct CommandError: Error, CustomStringConvertible {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String
    
    /// The name of the attempted command
    public let command: String?
    
    /// All available commands
    public let availableCommands: [String]

    /// See `CustomStringConvertible`.
    public var description: String {
        guard let name = command, !availableCommands.isEmpty else {
            return "\(self.identifier): \(self.reason)"
        }
        
        let suggestions: [(String, Int)] = availableCommands
            .map { ($0, $0.levenshteinDistance(to: name)) }
            .sorted(by: smallerDistance)
            .filter(distanceLessThan(3))
        
        guard !suggestions.isEmpty else {
            return "Error: \(self.reason)"
        }
        
        return """
        Error: \(self.reason)

        Did you mean this?

        \(suggestions.map { "\t\($0.0)" }.joined(separator: "\n"))
        """
    }

    /// Creates a new `CommandError`
    internal init(identifier: String, reason: String, forCommand command: String? = nil, availableCommands: [String] = []) {
        self.identifier = identifier
        self.reason = reason
        self.command = command
        self.availableCommands = availableCommands
    }
}


private func smallerDistance(lhs: (String, Int), rhs: (String, Int)) -> Bool {
    return lhs.1 < rhs.1
}

private func distanceLessThan(_ threshold: Int) -> (String, Int) -> Bool {
    return { command, distance in distance < threshold }
}

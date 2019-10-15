/// Errors working with the `Command` module.
public struct CommandError: Error, CustomStringConvertible {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String
    
    let name: String?
    let commands: [String]

    /// See `CustomStringConvertible`.
    public var description: String {
        guard let name = name else {
            return "\(self.identifier): \(self.reason)"
        }
        
        return """
        Error: \(self.reason)

        Did you mean this?
        
            \(suggestions(for: name, in: self.commands).joined(separator: "\n\t"))
        """
    }

    /// Creates a new `CommandError`
    internal init(identifier: String, reason: String, name: String? = nil, commands: [String] = []) {
        self.identifier = identifier
        self.reason = reason
        self.name = name
        self.commands = commands
    }
}

func suggestions(for name: String, in commands: [String]) -> [String] {
    return commands.filter { $0.levenshteinDistance(to: name) <= 2 }
}

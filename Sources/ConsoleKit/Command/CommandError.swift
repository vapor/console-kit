/// Errors working with the `Command` module.
public enum CommandError: Error, CustomStringConvertible {
    case missingCommand
    case unknownCommand(_ command: String, available: [String])
    case missingRequiredArgument(_ argument: String)
    case invalidArgumentType(_ argument: String, type: Any.Type)
    case invalidOptionType(_ option: String, type: Any.Type)

    /// See `CustomStringConvertible`.
    public var description: String {
        switch self {
        case .missingCommand:
            return "Error: Missing command"
        case let .unknownCommand(command, available: available):
            guard !available.isEmpty else {
                return "Error: Executable doesn't take a command"
            }
            
            let suggestions: [(String, Int)] = available
                .map { ($0, $0.levenshteinDistance(to: command)) }
                .sorted(by: smallerDistance)
                .filter(distanceLessThan(3))
            
            guard !suggestions.isEmpty else {
                return "Error: Unknown command `\(command)`"
            }
            
            return """
            Error: Unknown command `\(command)`
            
            Did you mean this?
            
            \(suggestions.map { "\t\($0.0)" }.joined(separator: "\n"))
            """
        case let .missingRequiredArgument(argument):
            return "Error: Missing required argument: \(argument)"
        case let .invalidArgumentType(argument, type: type):
            return "Error: Could not convert argument for \(argument) to \(type)"
        case let .invalidOptionType(option, type: type):
            return "Error: Could not convert option for \(option) to \(type)"
        }
    }
}


private func smallerDistance(lhs: (String, Int), rhs: (String, Int)) -> Bool {
    return lhs.1 < rhs.1
}

private func distanceLessThan(_ threshold: Int) -> (String, Int) -> Bool {
    return { command, distance in distance < threshold }
}

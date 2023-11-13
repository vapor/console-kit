/// Errors working with the `Command` module.
public enum CommandError: Error, Equatable, CustomStringConvertible {
    case missingCommand
    case unknownCommand(_ command: String, available: [String])
    case missingRequiredArgument(_ argument: String)
    case invalidArgumentType(_ argument: String, type: Any.Type)
    case invalidOptionType(_ option: String, type: Any.Type)

    /// See `Equatable`
    public static func == (lhs: CommandError, rhs: CommandError) -> Bool {
        switch (lhs, rhs) {
        case (.missingCommand, .missingCommand):
            return true
        case (let .unknownCommand(cmdL, available: availL), let .unknownCommand(cmdR, available: availR)):
            return cmdL == cmdR && availL.sorted() == availR.sorted()
        case (let .missingRequiredArgument(argL), let .missingRequiredArgument(argR)):
            return argL == argR
        case (let .invalidArgumentType(argL, type: tL), let .invalidArgumentType(argR, type: tR)):
            return argL == argR && tL == tR
        case (let .invalidOptionType(optL, type: tL), let .invalidOptionType(optR, type: tR)):
            return optL == optR && tL == tR
        default:
            return false
        }
    }
    
    /// See `CustomStringConvertible`.
    public var description: String {
        switch self {
        case .missingCommand:
            return "Missing command"
        case let .unknownCommand(command, available: available):
            guard !available.isEmpty else {
                return "Executable doesn't take a command"
            }
            
            let suggestions: [(String, Int)] = available
                .map { ($0, $0.levenshteinDistance(to: command)) }
                .sorted(by: smallerDistance)
                .filter(distanceLessThan(3))
            
            guard !suggestions.isEmpty else {
                return "Unknown command `\(command)`"
            }
            
            return """
            Unknown command `\(command)`
            
            Did you mean this?
            
            \(suggestions.map { "\t\($0.0)" }.joined(separator: "\n"))
            """
        case let .missingRequiredArgument(argument):
            return "Missing required argument: \(argument)"
        case let .invalidArgumentType(argument, type: type):
            return "Could not convert argument for `\(argument)` to \(type)"
        case let .invalidOptionType(option, type: type):
            return "Could not convert option for `\(option)` to \(type)"
        }
    }
}

private func smallerDistance(lhs: (String, Int), rhs: (String, Int)) -> Bool {
    return lhs.1 < rhs.1
}

private func distanceLessThan(_ threshold: Int) -> (String, Int) -> Bool {
    return { command, distance in distance < threshold }
}

extension CommandError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .missingCommand:
            return #".missingCommand"#
        case let .unknownCommand(command, available: available):
            return #".unknownCommand("\#(command)", available: \#(available))"#
        case let .missingRequiredArgument(argument):
            return #".missingRequiredArgument("\#(argument)")"#
        case let .invalidArgumentType(argument, type: type):
            return #".invalidArgumentType("\#(argument)", type: \#(type))"#
        case let .invalidOptionType(option, type: type):
            return #".invalidOptionType("\#(option)", type: \#(type))"#
        }
    }
}

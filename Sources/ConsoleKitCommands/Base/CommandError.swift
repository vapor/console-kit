/// Errors working with the ``ConsoleKitCommands`` module.
public enum CommandError: Error, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    case missingCommand
    case unknownCommand(String, available: [String])
    case missingRequiredArgument(String)
    case invalidArgumentType(String, type: any Any.Type)
    case invalidOptionType(String, type: any Any.Type)
    case unknownInput(String)

    // See `Equatable.==(_:_:)`.
    public static func == (lhs: CommandError, rhs: CommandError) -> Bool {
        switch (lhs, rhs) {
        case (.missingCommand, .missingCommand):
            return true
        case let (.unknownCommand(cmdL, availL), .unknownCommand(cmdR, availR)):
            return cmdL == cmdR && Set(availL) == Set(availR)
        case let (.missingRequiredArgument(argL), .missingRequiredArgument(argR)):
            return argL == argR
        case let (.invalidArgumentType(argL, tL), .invalidArgumentType(argR, tR)):
            return argL == argR && tL == tR
        case let (.invalidOptionType(optL, tL), .invalidOptionType(optR, tR)):
            return optL == optR && tL == tR
        case let (.unknownInput(inputL), .unknownInput(inputR)):
            return inputL == inputR
        default:
            return false
        }
    }
    
    // See `CustomStringConvertible.description`.
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
                .filter { $1 < 3 }
                .sorted { $0.1 < $1.1 }
            
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
        case let .unknownInput(input):
            return "Input not recognized: \(input)"
        }
    }

    // See `CustomDebugStringConvertible.debugDescription`.
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
        case let .unknownInput(input):
            return #".unknownInput("\#(input)")"#
        }
    }
}

@available(*, deprecated, message: "Subsumed by `CommandError`")
public struct ConsoleError: Error {
    public let identifier: String
    public let reason: String
}

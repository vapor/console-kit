/// Raw input for commands. Use this to parse options and arguments
/// for the command context.
public struct CommandInput {
    /// Global CommandLine input from Foundation.
    public static var commandLine = CommandInput(arguments: CommandLine.arguments)

    /// The input's raw arguments.
    public var arguments: [String]

    /// The current executable path
    public var executablePath: [String]

    /// Create a new CommandInput.
    public init(arguments: [String]) {
        guard arguments.count >= 1 else { fatalError("At least one argument (the executable path) is required") }
        var arguments = arguments
        executablePath = [arguments.popFirst()!]
        self.arguments = arguments
    }

    /// Parses the option from input, returning nil if it could
    /// not be found or throwing an error if invalid input is detected.
    mutating func parse(option: CommandOption) throws -> String? {
        // create a temporary [String?] array so it's
        // easier to mark positions as "consumed"
        var arguments = self.arguments.map { $0 as String? }
        defer { self.arguments = arguments.flatMap { $0 } }

        for (i, arg) in arguments.enumerated() {
            guard var arg = arg else { continue }

            if arg.hasPrefix("--") {
                // check if option matches
                guard arg == "--\(option.name)" else {
                    continue
                }
                // remove this option from the command input
                arguments[i] = nil
            } else if let short = option.short, arg.hasPrefix("-") {
                // has `-` prefix but not `--`
                // check if contains short name
                guard let index = arg.index(of: short) else {
                    continue
                }

                if arg.count == 1 {
                    // if just the `-` left, remove this arg
                    arguments[i] = nil
                } else {
                    // remove this option and update the args
                    _ = arg.remove(at: index)
                    arguments[i] = arg
                }
            } else {
                // not an option
                continue
            }

            // if we reach here, the option was found
            switch option.type {
            case .flag: return "true"
            case .value(let d):
                let supplied: String?

                // check if the next arg is available
                if i + 1 < arguments.count {
                    let next = arguments[i + 1]
                    // ensure it's non-nil and not an option
                    if next?.hasPrefix("-") == false {
                        supplied = next
                    } else {
                        supplied = nil
                    }
                } else {
                    supplied = nil
                }

                // value options need either a supplied value or a default
                guard let value = supplied ?? d else {
                    throw CommandError(
                        identifier: "optionValueRequired",
                        reason: "A value is required for option `\(option.name)`"
                    )
                }

                return value
            }
        }

        return nil
    }

    /// Parses the argument from input, returning `nil` if it
    /// could not be found.
    mutating func parse(argument: CommandArgument) throws -> String? {
        // create a temporary [String?] array so it's
        // easier to mark positions as "consumed"
        var arguments = self.arguments.map { $0 as String? }
        defer { self.arguments = arguments.flatMap { $0 } }

        for (i, arg) in arguments.enumerated() {
            guard let arg = arg else { continue }

            guard !arg.hasPrefix("-") else {
                // all options should have been parsed first
                return nil
            }

            arguments[i] = nil
            return arg
        }

        return nil
    }
}


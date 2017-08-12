import Console

public struct Input {
    public var executable: String
    public var arguments: [String]
    public var options: [String: String]

    public init(raw: [String]) throws {
        guard raw.count > 0 else {
            throw ConsoleError(identifier: "executableRequired", reason: "At least one argument is required.")
        }
        executable = raw[0]

        let raw = Array(raw.dropFirst())
        arguments = Input.parseArguments(from: raw)
        options = try Input.parseOptions(from: raw)
    }

    public static func parseArguments(from raw: [String]) -> [String] {
        return raw.flatMap { arg in
            guard !arg.hasPrefix("--") else {
                return nil
            }
            return arg
        }
    }

    public static func parseOptions(from raw: [String]) throws -> [String: String] {
        var options: [String: String] = [:]

        for arg in raw {
            guard arg.hasPrefix("--") else {
                continue
            }

            let val: String

            let parts = arg.dropFirst(2).split(separator: "=", maxSplits: 1).map(String.init)
            switch parts.count {
            case 1:
                val = "true"
            case 2:
                val = parts[1]
            default:
                throw ConsoleError(identifier: "invalidOption", reason: "Option \(arg) is incorrectly formatted.")
            }

            options[parts[0]] = val
        }

        return options
    }


}

extension Input {
    mutating func validate(using signature: GroupSignature) throws -> GroupInput {
        var validatedOptions: [String: String] = [:]

        // ensure we don't have any unexpected options
        for key in options.keys {
            guard signature.options.contains(where: { $0.name == key }) else {
                throw ConsoleError(identifier: "unexpectedOptions", reason: "Unexpected option `\(key)`.")
            }
        }

        // set all options to value or default
        for opt in signature.options {
            validatedOptions[opt.name] = options[opt.name] ?? opt.`default`
        }

        return .init(
            executable: executable,
            options: validatedOptions
        )
    }

    mutating func validate(using signature: CommandSignature) throws -> CommandInput {
        guard arguments.count <= signature.arguments.count else {
            throw ConsoleError(identifier: "unexpectedArguments", reason: "Too many arguments supplied.")
        }

        var validatedArguments: [String: String] = [:]
        for arg in signature.arguments {
            guard let argument = arguments.pop() else {
                throw ConsoleError(identifier: "insufficientArguments", reason: "Insufficient arguments supplied.")
            }
            validatedArguments[arg.name] = argument
        }

        var validatedOptions: [String: String] = [:]

        // ensure we don't have any unexpected options
        for key in options.keys {
            guard signature.options.contains(where: { $0.name == key }) else {
                throw ConsoleError(identifier: "unexpectedOptions", reason: "Unexpected option `\(key)`.")
            }
        }

        // set all options to value or default
        for opt in signature.options {
            validatedOptions[opt.name] = options[opt.name] ?? opt.`default`
        }

        return .init(
            executable: executable,
            arguments: validatedArguments,
            options: validatedOptions
        )
    }
}

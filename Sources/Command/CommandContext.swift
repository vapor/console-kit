import Console

public struct CommandContext {
    public var console: Console
    public var arguments: [String: String]
    public var options: [String: String]

    public init(
        console: Console,
        arguments: [String: String],
        options: [String: String]
    ) {
        self.console = console
        self.arguments = arguments
        self.options = options
    }

    public func requireOption(_ name: String) throws -> String {
        guard let value = options[name] else {
            throw CommandError(identifier: "optionRequired", reason: "Option `\(name)` is required.")
        }

        return value
    }

    public func argument(_ name: String) throws -> String {
        guard let value = arguments[name] else {
            throw CommandError(identifier: "argumentRequired", reason: "Argument `\(name)` is required.")
        }
        return value
    }

    static func make(
        from input: inout CommandInput,
        console: Console,
        for runnable: CommandRunnable
    ) throws -> CommandContext {
        var parsedArguments: [String: String] = [:]
        var parsedOptions: [String: String] = [:]

        let arguments: [CommandArgument]
        switch runnable.type {
        case .command(let a): arguments = a
        case .group: arguments = []
        }

        for arg in arguments {
            guard let value = try input.parse(argument: arg) else {
                throw CommandError(
                    identifier: "argumentRequired",
                    reason: "Argument `\(arg.name)` is required."
                )
            }
            parsedArguments[arg.name] = value
        }

        for opt in runnable.options {
            parsedOptions[opt.name] = try input.parse(option: opt)
        }

        guard input.arguments.count == 0 else {
            throw CommandError(
                identifier: "excessInput",
                reason: "Too many arguments or unsupported options were supplied."
            )
        }

        return CommandContext(
            console: console,
            arguments: parsedArguments,
            options: parsedOptions
        )
    }
}

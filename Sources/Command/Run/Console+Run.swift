/// Adds the ability to run `Command`s on a `Console`.
extension Console {
    /// Runs a `CommandRunnable` (`CommandGroup` or `Command`) of commands on this `Console` using the supplied `CommandInput`.
    ///
    ///     try console.run(group, input: &env.commandInput, on: container).wait()
    ///
    /// The `CommandInput` will be mutated, removing any used `CommandOption`s and `CommandArgument`s. If any excess input is left
    /// over after checking the command's signature, an error will be thrown.
    ///
    /// - parameters:
    ///     - runnable: `CommandGroup` or `Command` to run.
    ///     - input: Mutable `CommandInput` to parse `CommandOption`s and `CommandArgument`s from.
    ///     - container: `Container` to provide `EventLoop` access and services.
    /// - returns: A `Future` that will complete when the command finishes.
    public func run(_ runnable: CommandRunnable, input: inout CommandInput, on container: Container) -> Future<Void> {
        do {
            return try _run(runnable, input: &input, on: container)
        } catch {
            outputHelp(for: runnable, executable: input.executablePath.joined(separator: " "))
            return Future.map(on: container) {
                throw error
            }
        }
    }

    /// Runs the command, throwing if no commands are available.
    ///
    /// See `Console.run(...)`.
    private func _run(_ runnable: CommandRunnable, input: inout CommandInput, on container: Container) throws -> Future<Void> {
        // check -n and -y flags.
        if try input.parse(option: .flag(name: "no", short: "n", help: ["Automatically answers 'no' to all confirmiations."])) == "true" {
            confirmOverride = false
        } else if try input.parse(option: .flag(name: "yes", short: "y", help: ["Automatically answers 'yes' to all confirmiations."])) == "true" {
            confirmOverride = true
        }

        // try to run subcommand first
        switch runnable.type {
        case .group(let commands):
            if let name = try input.parse(argument: .argument(name: "subcommand")) {
                guard let subcommand = commands.commands[name] else {
                    throw CommandError(
                        identifier: "unknownCommand",
                        reason: "Unknown command `\(name)`",
                        source: .capture()
                    )
                }
                // executable should include all subcommands
                // to get to the desired command
                input.executablePath.append(name)
                return run(subcommand, input: &input, on: container)
            }
        case .command: break
        }

        if let help = try input.parse(option: .flag(name: "help", short: "h")) {
            assert(help == "true")
            outputHelp(for: runnable, executable: input.executablePath.joined(separator: " "))
            return .done(on: container)
        } else if let autocomplete = try input.parse(option: .flag(name: "autocomplete")) {
            assert(autocomplete == "true")
            try outputAutocomplete(for: runnable, executable: input.executablePath.joined(separator: " "))
            return .done(on: container)
        } else {
            // try to run the default command first
            switch runnable.type {
            case .group(let commands):
                if let defaultCommand = commands.defaultCommand {
                    guard let subcommand = commands.commands[defaultCommand] else {
                        throw CommandError(
                            identifier: "defaultCommand",
                            reason: "Unknown default command `\(defaultCommand)`",
                            source: .capture()
                        )
                    }
                    let exec = input.executablePath.joined()
                    output("Running default command: ".consoleText(.info) + exec.consoleText() + " " + defaultCommand.consoleText(.warning))
                    return run(subcommand, input: &input, on: container)
                }
            case .command: break
            }

            let context = try CommandContext.make(from: &input, console: self, for: runnable, on: container)
            return try runnable.run(using: context)
        }
    }
}

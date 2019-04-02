/// Adds the ability to run `Command`s on a `Console`.
extension Console {
    /// Runs a `CommandRunnable` (`CommandGroup` or `Command`) of commands on this `Console` using the supplied `CommandInput`.
    ///
    ///     try console.run(group, input: &env.commandInput, on: container).wait()
    ///
    /// The `CommandInput` will be mutated, removing any used `CommandOption`s and `CommandArgument`s.
    /// If any excess input is left over after checking the command's signature, an error will be thrown.
    ///
    /// - parameters:
    ///     - runnable: `CommandGroup` or `Command` to run.
    ///     - input: Mutable `CommandInput` to parse `CommandOption`s and `CommandArgument`s from.
    /// - returns: A `Future` that will complete when the command finishes.
    public func run(_ runnable: AnyCommandRunnable, input: inout CommandInput) -> EventLoopFuture<Void> {
        do {
            return try _run(runnable, input: &input)
        } catch {
            if error is CommandError {
                outputHelp(for: runnable, executable: input.executablePath.joined(separator: " "))
            }
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    /// Runs the command, throwing if no commands are available.
    ///
    /// See `Console.run(...)`.
    private func _run(_ runnable: AnyCommandRunnable, input: inout CommandInput) throws -> EventLoopFuture<Void> {
        // check -n and -y flags.
        if try input.parse(option: Option<Bool>.no) == "true" {
            confirmOverride = false
        } else if try input.parse(option: Option<Bool>.yes) == "true" {
            confirmOverride = true
        }

        // try to run subcommand first
        switch runnable.type {
        case .group(let commands):
            if let name = try input.parse(argument: Argument<String>.subcommand) {
                guard let subcommand = commands.commands[name] else {
                    throw CommandError(
                        identifier: "unknownCommand",
                        reason: "Unknown command `\(name)`"
                    )
                }
                // executable should include all subcommands
                // to get to the desired command
                input.executablePath.append(name)
                return run(subcommand, input: &input)
            }
        case .command: break
        }

        if let help = try input.parse(option: Option<Bool>.help) {
            assert(help == "true")
            outputHelp(for: runnable, executable: input.executablePath.joined(separator: " "))
            return self.eventLoopGroup.next().makeSucceededFuture(())
        } else if let autocomplete = try input.parse(option: Option<Bool>.autocomplete) {
            assert(autocomplete == "true")
            try outputAutocomplete(for: runnable, executable: input.executablePath.joined(separator: " "))
            return self.eventLoopGroup.next().makeSucceededFuture(())
        } else {
            // try to run the default command first
            switch runnable.type {
            case .group(let commands):
                if let defaultCommand = commands.defaultCommand {
                    guard let subcommand = commands.commands[defaultCommand] else {
                        throw CommandError(
                            identifier: "defaultCommand",
                            reason: "Unknown default command `\(defaultCommand)`"
                        )
                    }
                    let exec = input.executablePath.joined()
                    output("Running default command: ".consoleText(.info) + exec.consoleText() + " " + defaultCommand.consoleText(.warning))
                    return run(subcommand, input: &input)
                }
            case .command: break
            }

            let context = try AnyCommandContext.make(from: &input, console: self, for: runnable)
            return try runnable.run(using: context)
        }
    }
}

extension AnyOption {
    fileprivate static var no: Option<Bool> {
        return .flag(name: "no", short: "n", help: "Automatically answers 'no' to all confirmiations.")
    }
    
    fileprivate static var yes: Option<Bool> {
        return .flag(name: "yes", short: "y", help: "Automatically answers 'yes' to all confirmiations.")
    }
    
    fileprivate static var help: Option<Bool> {
        return .flag(name: "help", short: "h")
    }
    
    fileprivate static var autocomplete: Option<Bool> {
        return .flag(name: "autocomplete")
    }
}

extension AnyArgument {
    fileprivate static var subcommand: Argument<String> {
        return .init(name: "sucommand")
    }
}

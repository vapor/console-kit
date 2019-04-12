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
    public func run(_ runnable: AnyCommandRunnable, input: inout CommandInput) throws {
        // stores the latest command to run recursively so that we can
        // print a useful help message in the error case
        var current = runnable
        do {
            return try self._run(runnable, input: &input, current: &current)
        } catch {
            if error is CommandError {
                self.outputHelp(for: current, executable: input.executablePath.joined(separator: " "))
            }
            throw error
        }
    }

    /// Runs the command, throwing if no commands are available.
    ///
    /// See `Console.run(...)`.
    private func _run(_ runnable: AnyCommandRunnable, input: inout CommandInput, current: inout AnyCommandRunnable) throws {
        // check -n and -y flags.
        if try input.parse(option: Option<Bool>.no) == "true" {
            self.confirmOverride = false
        } else if try input.parse(option: Option<Bool>.yes) == "true" {
            self.confirmOverride = true
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
                current = subcommand
                try self._run(subcommand, input: &input, current: &current)
                return
            }
        case .command: break
        }

        if let help = try input.parse(option: Option<Bool>.help) {
            assert(help == "true")
            self.outputHelp(for: runnable, executable: input.executablePath.joined(separator: " "))
        } else if let autocomplete = try input.parse(option: Option<Bool>.autocomplete) {
            assert(autocomplete == "true")
            try self.outputAutocomplete(for: runnable, executable: input.executablePath.joined(separator: " "))
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
                    self.output("Running default command: ".consoleText(.info) + exec.consoleText() + " " + defaultCommand.consoleText(.warning))
                    current = subcommand
                    try self._run(subcommand, input: &input, current: &current)
                    return
                }
            case .command: break
            }

            current = runnable
            let context = try AnyCommandContext.make(from: &input, console: self, for: runnable)
            return try runnable.run(using: context)
        }
    }
}

private extension AnyOption {
    static var no: Option<Bool> {
        return .init(name: "no", short: "n", type: .flag, help: "Automatically answers 'no' to all confirmiations.")
    }
    
    static var yes: Option<Bool> {
        return .init(name: "yes", short: "y", type: .flag, help: "Automatically answers 'yes' to all confirmiations.")
    }
    
    static var help: Option<Bool> {
        return .init(name: "help", short: "h", type: .flag)
    }
    
    static var autocomplete: Option<Bool> {
        return .init(name: "autocomplete", type: .flag)
    }
}

private extension AnyArgument {
    static var subcommand: Argument<String> {
        return .init(name: "sucommand")
    }
}

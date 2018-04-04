import Async
import Console
import Service

extension Console {
    /// Runs a command or group of commands on this console using
    /// the supplied arguments.
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
                guard let subcommand = commands[name] else {
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

        if let help = try input.parse(option: .flag(name: "help")) {
            assert(help == "true")
            outputHelp(for: runnable, executable: input.executablePath.joined(separator: " "))
            return .done(on: container)
        } else if let autocomplete = try input.parse(option: .flag(name: "autocomplete")) {
            assert(autocomplete == "true")
            try outputAutocomplete(for: runnable, executable: input.executablePath.joined(separator: " "))
            return .done(on: container)
        } else {
            let context = try CommandContext.make(from: &input, console: self, for: runnable, on: container)
            return try runnable.run(using: context)
        }
    }
}

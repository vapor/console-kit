extension Console {
    public func run(_ group: Group, arguments: [String]) throws {
        var group = group

        var iterator = arguments.values.makeIterator()
        let isHelp = arguments.options["help"]?.bool ?? false

        var commands = group.commands
        var executable = group.id
        var foundCommand: Command? = nil

        while foundCommand == nil {
            guard let id = iterator.next() else {
                // no command and no more values
                printUsage(executable: executable, commands: commands)
                if isHelp {
                    // group help was requested
                    printHelp(executable: executable, group: group)
                    throw ConsoleError.help
                } else {
                    // cannot run groups
                    throw ConsoleError.noCommand
                }
            }

            guard let runnable = commands.filter({ $0.id == id }).first else {
                // value doesn't match any runnable items
                printUsage(executable: executable, commands: commands)
                throw ConsoleError.commandNotFound(id)
            }

            if let command = runnable as? Command {
                // got a command
                foundCommand = command
            } else if let g = runnable as? Group {
                // got a group of commands
                commands = g.commands
                executable = "\(executable) \(g.id)"
                group = g
            }
        }

        guard let command = foundCommand else {
            // no command was given
            throw ConsoleError.noCommand
        }

        if isHelp {
            // command help was requested
            printHelp(executable: executable, command: command)
            throw ConsoleError.help
        } else {
            // command should attempt to run
            var passThrough = arguments.values.dropFirst()

            // verify there are enough values to satisfy the signature
            if passThrough.count < command.signature.values.count {
                command.printUsage(executable: executable)
                throw ConsoleError.insufficientArguments
            }

            // pass through options
            for (name, value) in arguments.options {
                passThrough.append("--\(name)=\(value)")
            }

            try command.run(arguments: Array(passThrough))
        }
    }

    public func run(executable: String, commands: [Runnable], arguments: [String], help: [String]) throws {
        let group = Group(
            id: executable,
            commands: commands,
            help: help
        )

        try run(group, arguments: arguments)
    }

    public func printUsage(executable: String, commands: [Runnable]) {
        info("Usage: ", newLine: false)
        print("\(executable)", newLine: false)

        if commands.count > 0 {
            print(" <", newLine: false)
            print(commands.map { command in
                return command.id
            }.joined(separator: "|"), newLine: false)
            print(">")
        } else {
            print()
        }
    }

    public func printHelp(executable: String, group: Group) {
        printHelp(group.help)
    }

    public func printHelp(executable: String, command: Command) {
        command.printUsage(executable: executable)
        printHelp(command.help)
        command.printSignatureHelp()
    }

    public func printHelp(_ help: [String]) {
        for help in help {
            print(help)
        }
    }
}
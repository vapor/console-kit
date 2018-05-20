extension ConsoleProtocol {
    /**
        Runs a group of commands.
     
        The first argument should be the name of the 
        currently executing program.
     
        The second argument should be the id of the command
        that should run. Identifiers can recurse through groups.
     
        Following arguments and options will be passed through
        to the commands.
    */
    public func run(_ group: Group, arguments: [String]) throws {
        var group = group

        var iterator = arguments.values.makeIterator()
        let isHelp = arguments.flag("help")

        var commands = group.commands
        var executable = group.id
        var foundCommand: Command? = nil
        var passThrough = arguments.values.dropFirst()

        while foundCommand == nil {
            guard let id = iterator.next() else {
                // no command and no more values
                if isHelp {
                    // group help was requested
                    printHelp(executable: executable, group: group)
                    throw ConsoleError.help
                } else if let fallback = group.fallback {
                    foundCommand = fallback
                    break
                } else {
                    // cannot run groups
                    throw ConsoleError.noCommand
                }
            }

            guard let runnable = commands.filter({ $0.id == id }).first else {
                // value doesn't match any runnable items
                printHelp(executable: executable, group: group)
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
                
                // Remove the first id from the arguments so a command id is not found instead of a value with the `value(_:, arguments)` method.
                passThrough = passThrough.dropFirst()
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

            // verify there are enough values to satisfy the signature
            if passThrough.count < command.signature.values.count {
                command.printUsage(executable: executable)
                throw ConsoleError.insufficientArguments
            }

            // pass through options
            for (var name, value) in arguments.options {
                if name.count == 1 {
                    // Get the full flag name from the short version
                    #if swift(>=4.1)
                    name = command.signature.compactMap({ $0 as? Option })
                        .filter({ $0.short == Character(name) })
                        .first?.name ?? name
                    #else
                    name = command.signature.flatMap({ $0 as? Option })
                        .filter({ $0.short == Character(name) })
                        .first?.name ?? name
                    #endif
                }
                passThrough.append("--\(name)=\(value)")
            }

            try command.run(arguments: Array(passThrough))
        }
    }

    /**
        Runs an array of commands by creating a group
        then calling run(group: Group).
    */
    public func run(executable: String, commands: [Runnable], arguments: [String], help: [String]) throws {
        let group = Group(
            id: executable,
            commands: commands,
            help: help
        )

        try run(group, arguments: arguments)
    }
}

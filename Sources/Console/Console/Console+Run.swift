extension Console {
    public func run(executable: String, commands: [Command], arguments: [String]) throws {
        var iterator = arguments.values.makeIterator()

        guard let id = iterator.next() else {
            if arguments.options["help"]?.bool == true {
                help(executable: executable, commands: commands)
                throw ConsoleError.help
            } else {
                help(executable: executable, commands: commands)
                throw ConsoleError.noCommand
            }
        }

        guard let command = commands.filter({ $0.dynamicType.id == id }).first else {
            throw ConsoleError.commandNotFound
        }

        if arguments.options["help"]?.bool == true {
            help(executable: "\(executable) \(command.dynamicType.id)", commands: command.subcommands, help: command.help)
            throw ConsoleError.help
        } else {
            var passThrough = arguments.values.dropFirst()
            for (name, value) in arguments.options {
                passThrough.append("--\(name)=\(value)")
            }

            try command.run(arguments: Array(passThrough))
        }
    }
}
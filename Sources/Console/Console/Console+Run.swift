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
        let isHelp = arguments.options["help"]?.bool ?? false
        
        let commands = group.commands
        let executable = group.id
        
        for argument in arguments.values {
            
            guard let runnable = commands.filter({ $0.id == argument }).first else {
                // value doesn't match any runnable items
                printUsage(executable: executable, commands: commands)
                throw ConsoleError.commandNotFound(argument)
            }
            
            guard let command = runnable as? Command else {
                // no command was given
                throw ConsoleError.noCommand
            }
            
            if isHelp {
                // command help was requested
                printHelp(executable: executable, command: command)
                throw ConsoleError.help
            } else {
                // command should attempt to run
                
                let passThrough = arguments.options.map { (name, value) in
                    return "--\(name)=\(value)"
                }
                
                // verify there are enough values to satisfy the signature
                if passThrough.count < command.signature.values.count {
                    command.printUsage(executable: executable)
                    throw ConsoleError.insufficientArguments
                }
                
                try command.run(arguments: Array(passThrough))
            }
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

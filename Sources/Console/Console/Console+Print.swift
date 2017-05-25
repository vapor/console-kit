extension ConsoleProtocol {
    public func printUsage(executable: String) {
        info("Usage: ", newLine: false)
        print("\(executable) ", newLine: false)
        warning("command")
    }
    
    public func printRunnable(_ commands: [Runnable]) {
        info("Commands:")
        
        var maxWidth = 0
        for runnable in commands {
            let count = runnable.id.characters.count
            if count > maxWidth {
                maxWidth = count
            }
        }
        
        let leadingSpace = 2
        let width = maxWidth + leadingSpace
        
        for runnable in commands {
            print(String(
                repeating: " ", count: width - runnable.id.characters.count),
                  newLine: false
            )
            warning(runnable.id, newLine: false)
            
            if let group = runnable as? Group {
                for (i, help) in group.help.enumerated() {
                    print(" ", newLine: false)
                    if i != 0 {
                        print(String(
                            repeating: " ", count: width),
                              newLine: false
                        )
                    }
                    print(help)
                }
            }
            if let command = runnable as? Command {
                for (i, help) in command.help.enumerated() {
                    print(" ", newLine: false)
                    if i != 0 {
                        print(String(
                            repeating: " ", count: width),
                              newLine: false
                        )
                    }
                    print(help)
                }
            }
        }
    }

    public func printHelp(executable: String, group: Group) {
        printUsage(executable: executable)
        print("")
        printHelp(group.help)
        print("")
        printRunnable(group.commands)
        print("")
        print("Use `\(executable) ", newLine: false)
        warning("command", newLine: false)
        print(" --help` for more information on a command.")
    }

    public func printHelp(executable: String, command: Command) {
        command.printUsage(executable: executable)
        print("")
        printHelp(command.help)
        print("")
        command.printSignatureHelp()
    }

    public func printHelp(_ help: [String]) {
        for help in help {
            print(help)
        }
    }
}

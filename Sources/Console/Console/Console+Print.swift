extension ConsoleProtocol {
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

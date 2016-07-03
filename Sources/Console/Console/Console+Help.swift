extension Console {
    public func help(executable: String, commands: [Command], help: [String] = []) {
        info("Usage:", newLine: false)
        print(" \(executable) [", newLine: false)
        print(commands.map { command in
            return command.dynamicType.id
            }.joined(separator: "|"), newLine: false)
        print("]")

        if help.count > 1 {
            print()
            for help in help {
                print(help)
            }
        }
    }
}

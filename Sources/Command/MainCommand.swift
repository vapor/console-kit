/// A basic `CommandGroup` implementation.
internal struct BasicCommandGroup: CommandGroup {
    /// See `CommandGroup`.
    var commands: [String: CommandRunnable]

    /// See `CommandGroup`.
    var options: [CommandOption] {
        return defaultCommand?.options ?? []
    }

    /// Optional default command.
    var defaultCommand: CommandRunnable?

    /// See `CommandGroup`.
    var help: [String]

    /// Creates a new `BasicCommandGroup`.
    internal init(commands: [String: CommandRunnable], defaultCommand: CommandRunnable?, help: [String]) {
        self.help = help
        self.commands = commands
        self.defaultCommand = defaultCommand
    }

    /// See `CommandGroup`.
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        if let d = self.defaultCommand {
            return try d.run(using: context)
        } else {
            throw CommandError(identifier: "defaultCommand", reason: "No default command.", source: .capture())
        }
    }
}

/// A basic `CommandGroup` implementation.
internal struct BasicCommandGroup: CommandGroup {
    /// See `CommandGroup`.
    var commands: Commands

    /// See `CommandGroup`.
    var options: [CommandOption] {
        return []
    }

    /// See `CommandGroup`.
    var help: [String]

    /// Creates a new `BasicCommandGroup`.
    internal init(commands: Commands, help: [String]) {
        self.help = help
        self.commands = commands
    }

    /// See `CommandGroup`.
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        // should never run
        return .done(on: context.container)
    }
}

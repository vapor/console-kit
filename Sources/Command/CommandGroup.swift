/// A command that can be run through a console.
public protocol CommandGroup: CommandRunnable {
    /// A dictionary of runnable commands.
    typealias Commands = [String: CommandRunnable]

    /// This group's subcommands.
    var commands: Commands { get }
}

extension CommandGroup {
    /// See CommandRunnable.type
    public var type: CommandRunnableType {
        return .group(commands: commands)
    }
}

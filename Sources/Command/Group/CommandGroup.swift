/// A group of named commands that can be run through a `Console`.
///
/// Usually you will use `CommandConfig` to register commands and create a group.
///
///     var env = Environment.testing
///     let container: Container = ...
///     var config = CommandConfig()
///     config.use(CowsayCommand(), as: "cowsay")
///     let group = try config.resolve(for: container).group()
///     try console.run(group, input: &env.commandInput, on: container).wait()
///
/// You can create your own `CommandGroup` if you want to support custom `CommandOptions`.
public protocol CommandGroup: CommandRunnable {
    /// This group's subcommands.
    var commands: Commands { get }
}

extension CommandGroup {
    /// See `CommandRunnable`.
    public var type: CommandRunnableType {
        return .group(commands: commands)
    }
}

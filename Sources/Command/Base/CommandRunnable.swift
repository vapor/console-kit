/// Capable of being run on a `Console` using `Console.run(...)`.
/// - note: This base protocol should not be used directly. Conform to `Command` or `CommandGroup` instead.
public protocol CommandRunnable {
    /// The supported options.
    var options: [CommandOption] { get }

    /// Text that will be displayed when `--help` is passed.
    var help: [String] { get }

    /// The type of runnable. See `CommandRunnableType`.
    var type: CommandRunnableType { get }

    /// Runs the command against the supplied input.
    func run(using context: CommandContext) throws -> Future<Void>
}

/// Supported runnable types.
public enum CommandRunnableType {
    /// See `CommandGroup`
    case group(commands: Commands)
    /// See `Command`
    case command(arguments: [CommandArgument])
}

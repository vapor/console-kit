import Console

/// A command that can be run through a console.
public protocol Command: CommandRunnable {
    /// The required arguments.
    var arguments: [CommandArgument] { get }
}

extension Command {
    /// See CommandRunnable.type
    public var type: CommandRunnableType {
        return .command(arguments: arguments)
    }
}

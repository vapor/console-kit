import Service

/// Represents a top-level group of configured commands. This is usually created by calling `resolve(for:)` on `CommandConfig`.
public struct ConfiguredCommands: Service {
    /// Top-level available commands, stored by unique name.
    public let commands: [String: CommandRunnable]

    /// If set, this is the default top-level command that should run if no other commands are specified.
    public let defaultCommand: CommandRunnable?

    /// Creates a new `ConfiguredCommands` struct. This is usually done by calling `resolve(for:)` on `CommandConfig`.
    ///
    /// - parameters:
    ///     - commands: Top-level available commands, stored by unique name.
    ///     - defaultCommand: If set, this is the default top-level command that should run if no other commands are specified.
    public init(commands: [String: CommandRunnable] = [:], defaultCommand: CommandRunnable? = nil) {
        self.commands = commands
        self.defaultCommand = defaultCommand
    }

    /// Creates a `CommandGroup` for this `ConfiguredCommands`.
    ///
    ///
    ///
    /// - parameters:
    ///     - help: Optional help messages to include.
    /// - returns: A `CommandGroup` with commands and defaultCommand configured.
    public func group(help: [String] = []) -> CommandGroup {
        return BasicCommandGroup(commands: commands, defaultCommand: defaultCommand, help: help)
    }
}

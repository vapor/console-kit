/// Represents a top-level group of configured commands. This is usually created by calling `resolve(for:)` on `CommandConfig`.
public struct Commands: Service, ExpressibleByDictionaryLiteral {
    /// Top-level available commands, stored by unique name.
    public let commands: [String: CommandRunnable]

    /// If set, this is the default top-level command that should run if no other commands are specified.
    public let defaultCommand: String?

    /// Creates a new `ConfiguredCommands` struct. This is usually done by calling `resolve(for:)` on `CommandConfig`.
    ///
    /// - parameters:
    ///     - commands: Top-level available commands, stored by unique name.
    ///     - defaultCommand: If set, this is the default top-level command that should run if no other commands are specified.
    public init(commands: [String: CommandRunnable] = [:], defaultCommand: String? = nil) {
        self.commands = commands
        self.defaultCommand = defaultCommand
    }

    /// See `ExpressibleByDictionaryLiteral`.
    public init(dictionaryLiteral elements: (String, CommandRunnable)...) {
        var commands: [String: CommandRunnable] = [:]
        for (key, val) in elements {
            commands[key] = val
        }
        self.init(commands: commands, defaultCommand: nil)
    }

    /// Creates a `CommandGroup` for this `Commands`.
    ///
    ///     var env = Environment.testing
    ///     let container: Container = ...
    ///     var config = CommandConfig()
    ///     config.use(CowsayCommand(), as: "cowsay")
    ///     let group = try config.resolve(for: container).group()
    ///     try console.run(group, input: &env.commandInput, on: container).wait()
    ///
    /// - parameters:
    ///     - help: Optional help messages to include.
    /// - returns: A `CommandGroup` with commands and defaultCommand configured.
    public func group(help: [String] = []) -> CommandGroup {
        return BasicCommandGroup(commands: self, help: help)
    }
}

/// Represents a top-level group of configured commands. This is usually created by calling `resolve(for:)` on `CommandConfig`.
public struct Commands {
    /// Top-level available commands, stored by unique name.
    public var commands: [String: AnyCommand]

    /// If set, this is the default top-level command that should run if no other commands are specified.
    public var defaultCommand: AnyCommand?

    /// Creates a new `ConfiguredCommands` struct. This is usually done by calling `resolve(for:)` on `CommandConfig`.
    ///
    /// - parameters:
    ///     - commands: Top-level available commands, stored by unique name.
    ///     - defaultCommand: If set, this is the default top-level command that should run if no other commands are specified.
    public init(commands: [String: AnyCommand] = [:], defaultCommand: AnyCommand? = nil) {
        self.commands = commands
        self.defaultCommand = defaultCommand
    }
    
    /// Adds a `Command` instance to the config.
    ///
    ///     var commandConfig = CommandConfig.default()
    ///     commandConfig.use(barCommand, as: "bar")
    ///     services.register(commandConfig)
    ///
    /// - parameters:
    ///     - command: Some `CommandRunnable`. This type will be requested from the service container later.
    ///     - name: A unique name for running this command.
    ///     - isDefault: If `true`, this command will be set as the default command to run when none other are specified.
    ///                  Setting this overrides any previous default commands.
    public mutating func use(_ command: AnyCommand, as name: String, isDefault: Bool = false) {
        self.commands[name] = command
        if isDefault {
            self.defaultCommand = command
        }
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
    public func group(help: String = "") -> CommandGroup {
        return _Group(commands: self.commands, defaultCommand: self.defaultCommand, help: help)
    }
}

private struct _Group: CommandGroup {
    let commands: [String: AnyCommand]
    var defaultCommand: AnyCommand?
    let help: String
}

/// Represents a top-level group of configured commands. This is usually created by calling `resolve(for:)` on `Commands`.
public struct Commands {
    /// Top-level available commands, stored by unique name.
    public var commands: [String: AnyCommand]

    /// If set, this is the default top-level command that should run if no other commands are specified.
    public var defaultCommand: AnyCommand?

    /// Creates a new `ConfiguredCommands` struct. This is usually done by calling `resolve(for:)` on `Commands`.
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
    ///     var config = Commands()
    ///     config.use(barCommand, as: "bar")
    ///
    /// - parameters:
    ///     - command: Some `AnyCommand`. This type will be requested from the service container later.
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
    ///     var config = Commands()
    ///     config.use(CowsayCommand(), as: "cowsay")
    ///     let group = config.group(help: "Some help for cosway group...")
    ///
    ///     try console.run(group, with: context)
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

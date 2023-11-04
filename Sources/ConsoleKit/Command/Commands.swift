/// Represents a top-level group of configured commands. This is usually created by calling `resolve(for:)` on `Commands`.
public struct Commands: Sendable {
    /// Top-level available commands, stored by unique name.
    public var commands: [String: any AnyCommand]

    /// If set, this is the default top-level command that should run if no other commands are specified.
    public var defaultCommand: (any AnyCommand)?

    /// If `true`, an `autocomplete` subcommand will be added to any created `CommandGroup`.
    ///
    /// The `autocomplete` command generates shell completion scripts that can be loaded from shell configuration
    /// files to provide autocompletion for the entire command hierarchy and its command-line arguments.
    ///
    /// - Important: `enableAutocomplete` should only be set to `true` for a _root_ command group. Any nested
    ///   subcommands will automatically be included in the completion script generation process.
    ///
    public var enableAutocomplete: Bool

    /// Creates a new `ConfiguredCommands` struct. This is usually done by calling `resolve(for:)` on `Commands`.
    ///
    /// - parameters:
    ///     - commands: Top-level available commands, stored by unique name.
    ///     - defaultCommand: If set, this is the default top-level command that should run if no other commands are specified.
    ///     - enableAutocomplete: If `true`, an `autocomplete` subcommand will be added to any created `CommandGroup`.
    ///
    ///       The `autocomplete` command generates shell completion scripts that can be loaded from shell configuration
    ///       files to provide autocompletion for the entire command hierarchy and its command-line arguments.
    ///
    ///       `enableAutocomplete` should only be set to `true` for a _root_ command group. Any nested subcommands will
    ///       automatically be included in the completion script generation process.
    ///
    public init(commands: [String: any AnyCommand] = [:], defaultCommand: (any AnyCommand)? = nil, enableAutocomplete: Bool = false) {
        self.commands = commands
        self.defaultCommand = defaultCommand
        self.enableAutocomplete = enableAutocomplete
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
    public mutating func use(_ command: any AnyCommand, as name: String, isDefault: Bool = false) {
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
    public func group(help: String = "") -> any CommandGroup {
        var group = _Group(
            commands: self.commands,
            defaultCommand: self.defaultCommand,
            help: help
        )
        if self.enableAutocomplete {
            // First a placeholder uninitialized autocomplete command is added to the commands. The
            // second, _initialized_ autocomplete command immediately overwrites the first, but will
            // use it to provide completion for itself!
            group.commands["autocomplete"] = GenerateAutocompleteCommand()
            group.commands["autocomplete"] = GenerateAutocompleteCommand(rootCommand: group)
        }
        return group
    }
}

private struct _Group: CommandGroup, Sendable {
    var commands: [String: any AnyCommand]
    var defaultCommand: (any AnyCommand)?
    let help: String
}

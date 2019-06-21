/// Configures commands for a service container.
///
///     var commandConfig = CommandConfig.default()
///     /// You can register command types that will be lazily created
///     commandConfig.use(FooCommand.self, as: "foo")
///     /// You can also register pre-initialized instances of a command
///     commandConfig.use(barCommand, as: "bar")
///     services.register(commandConfig)
///
public struct CommandConfiguration {
    /// Internal storage
    private var commands: [String: AnyCommand]

    /// The default runnable
    private var defaultCommand: String?

    /// Create a new `CommandConfig`.
    public init() {
        self.commands = [:]
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
        commands[name] = command
        if isDefault {
            defaultCommand = name
        }
    }

    /// Resolves the configured commands to a `ConfiguredCommands` struct.
    ///
    /// - returns: `Commands` struct which contains initialized commands.
    /// - throws: Errors creating the lazy commands from the container.
    public func resolve() throws -> Commands {
        return .init(commands: commands, defaultCommand: defaultCommand)
    }
}

import Service

/// Configures commands for a service container.
///
///     var commandConfig = CommandConfig.default()
///     /// You can register command types that will be lazily created
///     commandConfig.use(FooCommand.self, as: "foo")
///     /// You can also register pre-initialized instances of a command
///     commandConfig.use(barCommand, as: "bar")
///     services.register(commandConfig)
///
public struct CommandConfig: Service {
    /// A lazily initialized `CommandRunnable`.
    public typealias LazyCommand = (Container) throws -> CommandRunnable

    /// Internal storage
    private var commands: [String: LazyCommand]

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
    public mutating func use(_ command: CommandRunnable, as name: String, isDefault: Bool = false) {
        commands[name] = { _ in command }
        if isDefault {
            defaultCommand = name
        }
    }

    /// Adds a `CommandRunnable` type to the config. This type will be lazily initialized later using a `Container`.
    ///
    ///     var commandConfig = CommandConfig.default()
    ///     commandConfig.use(FooCommand.self, as: "foo")
    ///     services.register(commandConfig)
    ///
    /// - parameters:
    ///     - command: `Type` of some `Command`. This type will be requested from the service container later.
    ///     - name: A unique name for running this command.
    ///     - isDefault: If `true`, this command will be set as the default command to run when none other are specified.
    ///                  Setting this overrides any previous default commands.
    public mutating func use<R>(_ command: R.Type, as name: String, isDefault: Bool = false) where R: CommandRunnable {
        commands[name] = { try $0.make(R.self) }
        if isDefault {
            defaultCommand = name
        }
    }

    /// Resolves the configured commands to a `ConfiguredCommands` struct.
    ///
    /// - parameters:
    ///     - container: `Container` to use for creating lazily initialized commands.
    /// - returns: `Commands` struct which contains initialized commands.
    /// - throws: Errors creating the lazy commands from the container.
    public func resolve(for container: Container) throws -> Commands {
        let commands = try self.commands.mapValues { lazy -> CommandRunnable in
            return try lazy(container)
        }

        return .init(commands: commands, defaultCommand: defaultCommand)
    }
}

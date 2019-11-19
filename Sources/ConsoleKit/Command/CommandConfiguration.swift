///// Configures commands for a service container.
/////
/////     var commandConfig = CommandConfig.default()
/////     /// You can register command types that will be lazily created
/////     commandConfig.use(FooCommand.self, as: "foo")
/////     /// You can also register pre-initialized instances of a command
/////     commandConfig.use(barCommand, as: "bar")
/////     services.register(commandConfig)
/////
//public struct CommandConfiguration {
//    /// Internal storage
//    private var commands: [String: AnyCommand]
//
//    /// The default runnable
//    private var defaultCommand: AnyCommand?
//
//    /// Create a new `CommandConfig`.
//    public init() {
//        self.commands = [:]
//    }
//
//
//
//    /// Resolves the configured commands to a `ConfiguredCommands` struct.
//    ///
//    /// - returns: `Commands` struct which contains initialized commands.
//    /// - throws: Errors creating the lazy commands from the container.
//    public func resolve() throws -> Commands {
//        return .init(commands: self.commands, defaultCommand: self.defaultCommand)
//    }
//}

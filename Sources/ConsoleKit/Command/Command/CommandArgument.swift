/// A required argument for a `Command`.
///
///     exec command <arg>
///
/// Used by `Command.arguments`.
///
///     struct CowsayCommand: Command {
///         var arguments: [CommandArgument] {
///             return [.argument(name: "message")]
///         }
///         ...
///     }
///
/// Fetch arguments using `CommandContext.argument(_:)`
///
///     struct CowsayCommand: Command {
///         ...
///         func run(using context: CommandContext) throws -> Future<Void> {
///             let message = try context.argument("message")
///             ...
///         }
///         ...
///     }
///
/// See `Command` for more information.
public struct CommandArgument {
    /// Creates a new `CommandArgument`.
    ///
    ///      let arguments: [CommandArgument] = [.argument(name: "message")]
    ///
    /// - parameters:
    ///     - name: This argument's unique name. Use this to fetch the argument from the `CommandContext`.
    public static func argument(name: String, help: [String] = []) -> CommandArgument {
        return .init(name: name, help: help)
    }

    /// The argument's unique name.
    public let name: String

    /// The arguments's help text when `--help` is passed.
    public let help: [String]

    /// Creates a new command argument
    /// Create via static methods.
    internal init(name: String, help: [String]) {
        self.name = name
        self.help = help
    }
}

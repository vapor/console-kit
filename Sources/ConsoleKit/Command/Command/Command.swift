/// A command that can be run through a `Console`.
///
/// Both `Command` and `CommandGroup` conform to `CommandRunnable` which provides the basic requirements
/// all command-like types need. In addition to those types, a `Command` requires zero or more `CommandArgument`s.
///
/// Below is a sample command that generates ASCII picture of a cow with a message.
///
///     struct CowsayCommand: Command {
///         var arguments: [CommandArgument] {
///             return [.argument(name: "message")]
///         }
///
///         var options: [CommandOption] {
///             return [
///                 .value(name: "eyes", short: "e"),
///                 .value(name: "tongue", short: "t"),
///             ]
///         }
///
///         var help: [String] {
///             return ["Generates ASCII picture of a cow with a message."]
///         }
///
///         func run(using context: CommandContext) throws -> Future<Void> {
///             let message = try context.argument("message")
///             let eyes = context.options["eyes"] ?? "oo"
///             let tongue = context.options["tongue"] ?? " "
///             let padding = String(repeating: "-", count: message.count)
///             let text: String = """
///               \(padding)
///             < \(message) >
///               \(padding)
///                       \\   ^__^
///                        \\  (\(eyes)\\_______
///                           (__)\\       )\\/\\
///                             \(tongue)  ||----w |
///                                ||     ||
///             """
///             context.console.print(text)
///             return .done(on: context.container)
///         }
///     }
///
///
/// Use `CommandConfig` to register commands and create a `CommandGroup`.
///
/// - note: You can also use `console.run(...)` to run a `CommandRunnable` manually.
///
/// Here is a simple example of the command in action, assuming it has been registered as `"cowsay"`.
///
///     swift run cowsay Hello
///       -----
///     < Hello >
///       -----
///               \   ^__^
///                \  (oo\_______
///                   (__)\       )\/\
///                        ||----w |
///                        ||     ||
///
/// And an example with flags:
///
///     swift run cowsay "I'm a dead cow" -e xx -t U
///       --------------
///     < I'm a dead cow >
///       --------------
///               \   ^__^
///                \  (xx\_______
///                   (__)\       )\/\
///                     U  ||----w |
///                        ||     ||
///
public protocol Command: CommandRunnable {
    /// This command's required `CommandArgument`s.
    ///
    /// See `CommandArgument` for more information.
    var arguments: [CommandArgument] { get }
}

extension Command {
    /// See `CommandRunnable`
    public var type: CommandRunnableType {
        return .command(arguments: arguments)
    }
}

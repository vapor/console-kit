/// A command that can be run through a `Console`.
///
/// Both `Command` and `CommandGroup` conform to `AnyCommand` which provides the basic requirements
/// all command-like types need. In addition to those types, a `Command` requires zero or more `CommandArgument`s.
///
/// Below is a sample command that generates ASCII picture of a cow with a message.
///
///     struct CowsayCommand: AsyncCommand {
///         public struct Signature: CommandSignature {
///             @Argument(name: "message")
///             var message: String
///
///             @Option(name: "eyes", short: "e")
///             var eyes: String?
///
///             @Option(name: "tongue", short: "t")
///             var tongue: String?
///
///             public init() { }
///         }
///
///         var help: String {
///             "Generates ASCII picture of a cow with a message."
///         }
///
///         public init() { }
///         public func run(using context: CommandContext, signature: Signature) async throws {
///             let eyes = signature.eyes ?? "oo"
///             let tongue = signature.tongue ?? " "
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
///         }
///     }
///
/// Meanwhile you can use the Command in an executable target like:
///
///     let console: Console = Terminal()
///     var input = CommandInput(arguments: CommandLine.arguments)
///     var context = CommandContext(console: console, input: input)
///
///     try await console.run(CoswayCommand(), with: context)
///
/// Use `Commands` to register commands and create a `CommandGroup`.
///
/// - note: You can also use `console.run(...)` to run an `AnyAsyncCommand` manually.
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
public protocol AsyncCommand: AnyAsyncCommand {
    associatedtype Signature: CommandSignature
    func run(using context: CommandContext, signature: Signature) async throws
}

extension AsyncCommand {
    public func run(using context: inout CommandContext) async throws {
        let signature = try Signature(from: &context.input)
        guard context.input.arguments.isEmpty else {
            let input = context.input.arguments.joined(separator: " ")
            throw ConsoleError.init(identifier: "unknownInput", reason: "Input not recognized: \(input)")
        }
      try await self.run(using: context, signature: signature)
    }

    public func outputAutoComplete(using context: inout CommandContext) {
        var autocomplete: [String] = []
        autocomplete += Signature.reference.arguments.map { $0.name }
        autocomplete += Signature.reference.options.map { "--" + $0.name }
        context.console.output(autocomplete.joined(separator: " "), style: .plain)
    }

    public func outputHelp(using context: inout CommandContext) {
        context.console.output("Usage: ".consoleText(.info) + context.input.executable.consoleText() + " ", newLine: false)
        Signature.reference.outputHelp(help: self.help, using: &context)
    }
}

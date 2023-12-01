/// A type-erased `Command`.
public protocol AnyAsyncCommand: Sendable {
    /// Text that will be displayed when `--help` is passed.
    var help: String { get }
    
    /// Runs the command against the supplied input.
    func run(using context: inout CommandContext) async throws
    func outputAutoComplete(using context: inout CommandContext) throws
    func outputHelp(using context: inout CommandContext) throws

    /// Renders the shell completion script functions for the command and any descendent subcommands.
    func renderCompletionFunctions(using context: CommandContext, shell: Shell) -> String
}

extension AnyAsyncCommand {
    public func outputAutoComplete(using context: inout CommandContext) {
        // do nothing
    }

    public func outputHelp(using context: inout CommandContext) {
        // do nothing
    }

    public func renderCompletionFunctions(using context: CommandContext, shell: Shell) -> String {
        ""
    }
}

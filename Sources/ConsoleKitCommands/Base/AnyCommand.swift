/// A type-erased `Command`.
public protocol AnyCommand: Sendable, AnyAsyncCommand {
    /// Text that will be displayed when `--help` is passed.
    var help: String { get }

    /// Runs the command against the supplied input.
    func run(using context: inout CommandContext) throws
    func outputAutoComplete(using context: inout CommandContext) throws
    func outputHelp(using context: inout CommandContext) throws

    /// Renders the shell completion script functions for the command and any descendent subcommands.
    func renderCompletionFunctions(using context: CommandContext, shell: Shell) -> String
}

extension AnyCommand {
    public func outputAutoComplete(using context: inout CommandContext) {
        // do nothing
    }

    public func outputHelp(using context: inout CommandContext) {
        // do nothing
    }

    public func renderCompletionFunctions(using context: CommandContext, shell: Shell) -> String {
        ""
    }

    // we need to have a sync environment so the compiler uses the sync run method over the async version
    private func syncRun(using context: inout CommandContext) throws {
        try self.run(using: &context)
    }

    public func run(using context: inout CommandContext) async throws {
        try self.syncRun(using: &context)
    }
}

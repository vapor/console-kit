/// A type-erased `CommandContext`
public struct CommandContext {
    /// The `Console` this command was run on.
    public var console: Console
    
    /// The parsed arguments (according to declared signature).
    public var input: CommandInput

    public var userInfo: [AnyHashable: Any]
    
    /// Create a new `AnyCommandContext`.
    public init(
        console: Console,
        input: CommandInput
    ) {
        self.console = console
        self.input = input
        self.userInfo = [:]
    }
}

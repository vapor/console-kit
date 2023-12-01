import protocol ConsoleKitTerminal.Console
import struct ConsoleKitTerminal.AnySendableHashable

/// A type-erased `CommandContext`
public struct CommandContext: Sendable {
    /// The `Console` this command was run on.
    public var console: any Console

    /// The parsed arguments (according to declared signature).
    public var input: CommandInput

    public var userInfo: [AnySendableHashable: any Sendable]

    /// Create a new `AnyCommandContext`.
    public init(
        console: any Console,
        input: CommandInput
    ) {
        self.console = console
        self.input = input
        self.userInfo = [:]
    }
}

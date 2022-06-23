import NIOCore
import NIOPosix
/// A type-erased `CommandContext`
public struct CommandContext {
    /// The `Console` this command was run on.
    public var console: Console
    
    /// The parsed arguments (according to declared signature).
    public var input: CommandInput

    public var userInfo: [AnyHashable: Any]
    
    public let eventLoopGroup: EventLoopGroup
    
    /// Create a new `AnyCommandContext`.
    public init(
        console: Console,
        input: CommandInput,
        eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    ) {
        self.console = console
        self.input = input
        self.userInfo = [:]
        self.eventLoopGroup = eventLoopGroup
    }
}

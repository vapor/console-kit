import NIO

/// A basic `CommandGroup` implementation.
internal struct BasicCommandGroup: CommandGroup {
    
    /// See `CommandRunnable`.
    struct Signature: Inputs { }
    
    /// See `CommandGroup`.
    var commands: Commands

    /// See `CommandGroup`.
    var help: String?

    /// Creates a new `BasicCommandGroup`.
    internal init(commands: Commands, help: String?) {
        self.help = help
        self.commands = commands
    }

    /// See `CommandGroup`.
    func run(using context: CommandContext<BasicCommandGroup>) throws -> EventLoopFuture<Void> {
        // should never run
        return context.eventLoop.makeSucceededFuture(())
    }
}

/// A basic `CommandGroup` implementation.
internal struct BasicCommandGroup: CommandGroup {
    /// See `CommandRunnable`.
    struct Signature: CommandSignature { }
    
    /// See `CommandRunnable`.
    let signature: BasicCommandGroup.Signature = Signature()
    
    /// See `CommandGroup`.
    var commands: Commands

    /// See `CommandGroup`.
    let help: String

    /// Creates a new `BasicCommandGroup`.
    internal init(commands: Commands, help: String) {
        self.help = help
        self.commands = commands
    }

    /// See `CommandGroup`.
    func run(using context: CommandContext<BasicCommandGroup>) throws {
        // should never run
    }
}

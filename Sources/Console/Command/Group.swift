public class Group: Runnable {
    public var id: String
    public var commands: [Runnable]
    public var help: [String]
    public var fallback: Command?

    public init(id: String, commands: [Runnable], help: [String], fallback: Command? = nil) {
        self.id = id
        self.commands = commands
        self.help = help
        self.fallback = fallback
    }
}

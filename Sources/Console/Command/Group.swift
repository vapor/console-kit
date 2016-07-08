public class Group: Runnable {
    public var id: String
    public var commands: [Runnable]
    public var help: [String]

    public init(id: String, commands: [Runnable], help: [String]) {
        self.id = id
        self.commands = commands
        self.help = help
    }
}

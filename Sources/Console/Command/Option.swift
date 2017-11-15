public struct Option: Argument {
    public var name: String
    public var short: Character?
    public var help: [String]

    public init(name: String, short: Character? = nil, help: [String] = []) {
        self.name = name
        self.short = short
        self.help = help
    }
}

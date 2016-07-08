public struct Option: Argument {
    public var name: String
    public var help: [String]

    public init(name: String, help: [String] = []) {
        self.name = name
        self.help = help
    }
}

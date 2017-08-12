public struct GroupSignature {
    public let runnables: [String: Runnable]
    public let options: [Option]
    public let help: [String]

    public init(runnables: [String: Runnable], options: [Option], help: [String]) {
        self.runnables = runnables
        self.options = options
        self.help = help
    }

    public struct Option {
        public let name: String
        public let help: [String]
        public let `default`: String?

        public init(name: String, help: [String] = [], default: String? = nil) {
            self.name = name
            self.help = help
            self.`default` = `default`
        }
    }
}

public struct CommandSignature {
    public let arguments: [Argument]
    public let options: [Option]
    public let help: [String]

    public init(arguments: [Argument], options: [Option], help: [String]) {
        self.arguments = arguments
        self.options = options
        self.help = help
    }

    public struct Argument {
        public let name: String
        public let help: [String]

        public init(name: String, help: [String] = []) {
            self.name = name
            self.help = help
        }
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

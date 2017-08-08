public enum Runnable {
    case command(Command)
    case group(Group)
}

extension Runnable {
    public var help: [String] {
        switch self {
        case .command(let command):
            return command.signature.help
        case .group(let group):
            return group.signature.help
        }
    }
}

public protocol Command: Runnable {
    var console: ConsoleProtocol { get }
    func run(arguments: [String]) throws

    var signature: [Argument] { get }
    var help: [String] { get }
}

extension Command {
    public var signature: [Argument] {
        return []
    }
    public var help: [String] {
        return []
    }
}

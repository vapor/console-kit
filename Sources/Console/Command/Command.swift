import Polymorphic

public protocol Command: Runnable {
    var console: Console { get }
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

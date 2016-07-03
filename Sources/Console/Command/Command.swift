import Polymorphic

public protocol Command {
    static var id: String { get }
    var console: Console { get }
    func run(arguments: [String]) throws

    var signature: [Signature]
    var subcommands: [Command] { get }
    var help: [String] { get }
}

extension Command {
    public var signature: [Signature] {
        return []
    }
    
    public var subcommands: [Command] {
        return []
    }

    public var help: [String] {
        return []
    }
}

import Console

public protocol Group {
    var signature: GroupSignature { get }
    func run(using console: Console, with input: GroupInput) throws
}

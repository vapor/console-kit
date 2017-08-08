import Consoles

public protocol Command {
    var signature: CommandSignature { get }
    func run(using console: Console, with input: CommandInput) throws
}

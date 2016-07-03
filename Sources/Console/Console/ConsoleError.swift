public enum ConsoleError: ErrorProtocol {
    case help
    case noExecutable
    case noCommand
    case commandNotFound
    case cancelled
    case execute(Int)
}

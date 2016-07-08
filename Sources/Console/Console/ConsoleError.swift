public enum ConsoleError: ErrorProtocol {
    case help
    case noExecutable
    case noCommand
    case insufficientArguments
    case argumentNotFound
    case commandNotFound(String)
    case cancelled
    case execute(Int)
    case backgroundExecute(Int, String)
}

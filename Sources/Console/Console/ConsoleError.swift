import Core

public enum ConsoleError: Swift.Error {
    case help
    case noExecutable
    case noCommand
    case insufficientArguments
    case argumentNotFound
    case commandNotFound(String)
    case cancelled
    case spawnProcess
    case execute(code: Int)
    case backgroundExecute(code: Int, error: String, output: String)
    case fileOrDirectoryNotFound
}

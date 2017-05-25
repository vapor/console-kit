public enum ConsoleClear {
    case screen
    case line
}

extension ConsoleProtocol {
    public func clear(lines: Int) {
        for _ in 0..<lines {
            clear(.line)
        }
    }
}

public enum ConsoleClear {
    case screen
    case line
}

extension ConsoleProtocol {
    public func clear(_ clear: ConsoleClear) {
        didOutputLines(count: -1)
        stream(.clear(clear))
    }
    
    public func clear(lines: Int) {
        for _ in 0..<lines {
            clear(.line)
        }
    }
}

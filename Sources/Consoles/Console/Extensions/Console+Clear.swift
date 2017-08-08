extension Console {
    public func clear(_ clear: Clear) throws {
        didOutputLines(count: -1)
        try action(.clear(clear))
    }

    public func clear(lines: Int) throws {
        for _ in 0..<lines {
            try clear(.line)
        }
    }
}


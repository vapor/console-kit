extension Console {
    public func pushEphemeral() {
        depth += 1
        levels[depth] = 0
    }

    public func popEphemeral() throws {
        let lines = levels[depth] ?? 0
        guard lines > 0 else {
            levels[depth] = nil
            depth -= 1
            return
        }

        for _ in 0..<lines {
            clear(.line)
        }

        // remember to reset depth after or else
        // the lines will get messed up
        levels[depth] = nil
        depth -= 1
    }

    private var depth: Int {
        get { return extend.get(\Self.depth, default: 0) }
        set { extend.set(\Self.depth, to: newValue) }
    }

    private var levels: [Int: Int] {
        get { return extend.get(\Self.levels, default: [:]) }
        set { extend.set(\Self.levels, to: newValue) }
    }

    internal func didOutputLines(count: Int) {
        guard depth > 0 else {
            return
        }

        if let existing = levels[depth] {
            levels[depth] = existing + count
        } else {
            levels[depth] = count
        }
    }
}


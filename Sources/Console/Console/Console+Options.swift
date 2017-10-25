extension Sequence where Iterator.Element == String {
    public var options: [String: String] {
        var iteration = Array(self.enumerated())
        var options: [String: String] = [:]

        for option in iteration.filter({ $0.element.hasPrefix("--") }) {
            let parts = option.element.characters.split(separator: "-", maxSplits: 2, omittingEmptySubsequences: false)

            guard parts.count == 3 else {
                continue
            }

            let token = parts[2].split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)

            let name = String(token[0])

            if token.count == 2 {
                options[name] = String(token[1])
            } else {
                options[name] = true.string
            }
            iteration.remove(at: option.offset)
        }
        
        for option in iteration.filter({ $0.element.hasPrefix("-") }) {
            let parts = option.element.characters.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
            
            guard parts.count == 2 else {
                continue
            }
            
            let token = parts[1].split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            
            let name = String(token[0])
            
            if token.count == 2 {
                options[name] = String(token[0])
            } else {
                options[name] = true.string
            }
        }
        
        return options
    }

    public var values: [String] {
        return filter { !$0.hasPrefix("-") }
    }

    public func argument(_ name: String) throws -> String {
        return ""
    }

    public func option(_ name: String) -> String? {
        return options[name]
    }

    public func flag(_ name: String) -> Bool {
        return option(name)?.bool == true
    }
}

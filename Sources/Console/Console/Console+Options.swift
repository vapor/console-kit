import Polymorphic

extension Sequence where Iterator.Element == String {
    public var options: [String: Polymorphic] {
        var options: [String: Polymorphic] = [:]

        for option in filter({ $0.hasPrefix("--") }) {
            let parts = option.characters.split(separator: "-", maxSplits: 2, omittingEmptySubsequences: false)

            guard parts.count == 3 else {
                continue
            }

            let token = parts[2].split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)

            let name = String(token[0])

            if token.count == 2 {
                options[name] = String(token[1])
            } else {
                options[name] = true
            }
        }
        
        return options
    }

    public var values: [String] {
        return filter { !$0.hasPrefix("--") }
    }

    public func argument(_ name: String) throws -> String {
        return ""
    }

    public func option(_ name: String) -> Polymorphic? {
        return options[name]
    }

    public func flag(_ name: String) -> Bool {
        return option(name)?.bool == true
    }
}

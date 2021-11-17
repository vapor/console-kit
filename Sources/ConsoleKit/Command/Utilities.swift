extension Array {
    /// Pops the first element from the array.
    mutating func popFirst() -> Element? {
        guard let pop = first else {
            return nil
        }
        self = Array(dropFirst())
        return pop
    }
}

extension Array where Element == String {
    var longestCount: Int {
        var count = 0

        for item in self {
            if item.count > count {
                count = item.count
            }
        }

        return count
    }
}

extension String {
    func leftPad(to padding: Int) -> String {
        return String(repeating: " ", count: padding) + self
    }
}

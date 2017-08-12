extension Array where Element == String {
    mutating func pop() -> String? {
        guard let pop = first else {
            return nil
        }
        self = Array(dropFirst())
        return pop
    }
}

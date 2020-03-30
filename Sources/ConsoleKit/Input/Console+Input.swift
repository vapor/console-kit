extension Console {
    /// See `Console.input(isSecure:)`
    ///
    /// - note: Defaults to non-secure input.
    public func input() -> String {
        return input(isSecure: false)
    }
}

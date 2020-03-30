extension Console {
    /// See `Console.input(isSecure:)`
    ///
    /// - note: Defaults to non-secure input.
    public func input(isSecure: Bool = false) -> String {
        return input(isSecure: false)
    }
}

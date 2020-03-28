extension Console {
    /// See `Console.read(isSecure:)`
    ///
    /// - note: Defaults to non-secure input.
    public func read() -> String? {
        return read(isSecure: false)
    }

    /// See `Console.input(isSecure:)`
    ///
    /// - note: Defaults to non-secure input.
    public func input(isSecure: Bool = false) -> String {
        return read(isSecure: isSecure) ?? ""
    }
}

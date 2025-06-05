extension Console {
    /// See ``Console/input(isSecure:)``
    ///
    /// - Parameter isSecure: If `true`, the input should not be shown while it is entered.
    public func input(isSecure: Bool = false) -> String {
        return self.input(isSecure: isSecure)
    }
}

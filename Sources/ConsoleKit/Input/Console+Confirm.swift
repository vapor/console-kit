extension Console {
    /// Requests yes / no confirmation from the user after a prompt.
    ///
    ///     if console.confirm("Delete everything?") {
    ///         console.warning("Deleting everything!")
    ///     } else {
    ///         console.print("OK, I won't.")
    ///     }
    ///
    /// The above code outputs:
    ///
    ///     Delete everything?
    ///     > no
    ///     OK, I won't.
    ///
    /// This method will attempt to convert the response into a `Bool` using `String.bool`.
    /// It will continue to ask until the result is a proper format, providing additional help after
    /// a few failed attempts.
    ///
    /// See `Console.confirmOverride` for enabling automatic answers to all confirmation prompts.
    ///
    /// - parameters:
    ///     - prompt: `ConsoleText` to display before the confirmation input.
    /// - returns: `true` if the user answered yes, false if no.
    public func confirm(_ prompt: ConsoleText) -> Bool {
        var i = 0
        var result = ""

        /// continue to ask until the result can be converted to a bool
        while Bool(yn: result) == nil {
            output(prompt)
            if i >= 1 {
                output("[y]es or [n]o> ".consoleText(.info), newLine: false)
            } else {
                output("y/n> ".consoleText(.info), newLine: false)
            }

            // Defaults for all confirms for headless environments
            if let override = confirmOverride {
                let message = override ? "yes" : "no"
                output(message.consoleText(.warning))
                return override
            }

            result = input().lowercased()
            i += 1
        }

        return Bool(yn: result)!
    }

    /// If set, all calls to `confirm(_:)` will use this value instead of asking the user.
    public var confirmOverride: Bool? {
        get { return self.userInfo["confirmOverride"] as? Bool }
        set { self.userInfo["confirmOverride"] = newValue }
    }
}

private extension Bool {
    init?(yn: String) {
        switch yn.lowercased() {
        case "y", "yes": self = true
        case "n", "no": self = false
        default: return nil
        }
    }
}

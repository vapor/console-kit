extension Console {
    /// Requests yes/no confirmation from
    /// the console.
    public func confirm(_ prompt: String, style: ConsoleStyle = .info) -> Bool {
        var i = 0
        var result = ""
        while result != "y" && result != "yes" && result != "n" && result != "no" {
            output(prompt.consoleText(style))
            if i >= 1 {
                output("[y]es or [n]o> ".consoleText(style), newLine: false)
            } else {
                output("y/n> ".consoleText(style), newLine: false)
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

        return result == "y" || result == "yes"
    }

    public var confirmOverride: Bool? {
        get { return extend.get(\Self.confirmOverride, default: nil) }
        set { extend.set(\Self.confirmOverride, to: newValue) }
    }
}

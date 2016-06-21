extension Console {
    /**
        Requests yes/no confirmation from
        the console.
    */
    public func confirm(_ prompt: String, style: ConsoleStyle = .info) -> Bool {
        var i = 0
        var result = ""
        while result != "y" && result != "yes" && result != "n" && result != "no" {
            output(prompt, style: style)
            if i >= 1 {
                output("[y]es or [n]o>", style: style, newLine: false)
            } else {
                output("y/n>", style: style, newLine: false)
            }
            result = input().lowercased()
            i += 1
        }

        return result == "y" || result == "yes"
    }
}

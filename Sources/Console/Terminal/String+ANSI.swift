extension String {
    /**
        Conversts a String to a full ANSI command.
    */
    var ansi: String {
        return "\u{001B}[" + self
    }
}

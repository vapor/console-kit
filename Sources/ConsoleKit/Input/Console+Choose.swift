extension Console {
    /// Prompts the user to choose an item from the supplied array. The chosen item will be returned.
    ///
    ///     let color = console.choose("Favorite color?", from: ["Pink", "Blue"])
    ///     console.output("You chose: " + color.consoleText())
    ///
    /// The above code will output:
    ///
    ///     Favorite color?
    ///     1: Pink
    ///     2: Blue
    ///     >
    ///
    /// Upon answering, the prompt and options will be cleared from the console and only the output will remain:
    ///
    ///     You chose: Blue
    ///
    /// This method calls `choose(_:from:display:)` using `CustomStringConvertible` to display each element.
    ///
    /// - parameters:
    ///     - prompt: `ConsoleText` prompt to display to the user before listing options.
    ///     - array: Array of `CustomStringConvertible` items to choose from.
    /// - returns: Element from `array` that the user chose.
    public func choose<T>(_ prompt: ConsoleText, from array: [T]) -> T
        where T: CustomStringConvertible
    {
        return choose(prompt, from: array, display: { $0.description.consoleText() })
    }

    /// Prompts the user to choose an item from the supplied array. The chosen item will be returned.
    ///
    ///     let color = console.choose("Favorite color?", from: ["Pink", "Blue"])
    ///     console.output("You chose: " + color.consoleText())
    ///
    /// The above code will output:
    ///
    ///     Favorite color?
    ///     1: Pink
    ///     2: Blue
    ///     >
    ///
    /// Upon answering, the prompt and options will be cleared from the console and only the output will remain:
    ///
    ///     You chose: Blue
    ///
    /// See `choose(_:from:)` which uses `CustomStringConvertible` to display each element.
    ///
    /// - parameters:
    ///     - prompt: `ConsoleText` prompt to display to the user before listing options.
    ///     - array: Array of `CustomStringConvertible` items to choose from.
    ///     - display: A closure for converting each element of `array` to a `ConsoleText` for display.
    /// - returns: Element from `array` that the user chose.
    public func choose<T>(_ prompt: ConsoleText, from array: [T], display: (T) -> ConsoleText) -> T {
        output(prompt)
        array.enumerated().forEach { idx, item in
            let offset = idx + 1
            output("\(offset): ".consoleText(.info), newLine: false)
            let description = display(item)
            output(description)
        }

        var res: T?
        while res == nil {
            output("> ".consoleText(.info), newLine: false)
            guard let raw = read() else {
                // EOF on stdin. What to do here? There's no way to know what a
                // safe default to return would be. For now, crash with as
                // helpful an error as possible. Alternatives: Hang forever.
                self.error("EOF trying to read selection, we have to crash here.", newLine: true)
                self.report(error: "EOF trying to read selection, we have to crash here.", newLine: true)
                fatalError("EOF trying to read selection, we have to crash here.")
            }
            guard let idx = Int(raw), (1...array.count).contains(idx) else {
                // .count is implicitly offset, no need to adjust
                clear(.line)
                continue
            }

            // undo previous offset back to 0 indexing
            let offset = idx - 1
            res = array[offset]
        }

        // + 1 for > input line
        // + 1 for title line
        let lines = array.count + 2
        for _ in 1...lines {
            clear(.line)
        }

        return res!
    }
}

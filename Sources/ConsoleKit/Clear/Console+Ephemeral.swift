/// Adds the ability to dynamically clear pre-defined sections of outputted text.
///
/// This is useful for creating interactive console applications that can guide users
/// through a process and then clean up the terminal before continuing.
///
///     console.print("Logging in...")
///     if !loggedIn {
///         // all output after this call can be cleared by calling `popEphemeral()`
///         console.pushEphemeral()
///
///         // ask the user some questions
///         let password = console.ask("Enter password:")
///         // login with password ...
///
///         // clear all output since `pushEphemeral()`
///         console.popEphemeral()
///     } else {
///         // already logged in
///     }
///     console.print("Logged in!")
///     console.print("Doing something...")
///
/// `Console`s supporting this must call `didOutputLines(count:)` every time text is outputted to the console
/// so that the number of lines to clear can be tracked.
extension Console {
    /// Pushes a new ephemeral console state. All text outputted to the console immidiately after this call
    /// can be cleared by using `popEphemeral()`.
    ///
    /// This method can be called as many times as desired. Calls to `popEphemeral()` will work in reverse order.
    ///
    ///     console.print("a")
    ///     console.pushEphemeral()
    ///     console.print("b")
    ///     console.print("c")
    ///     console.pushEphemeral()
    ///     console.print("d")
    ///     console.print("e")
    ///     console.print("f")
    ///     console.popEphemeral() // removes "d", "e", and "f" lines
    ///     console.print("g")
    ///     console.popEphemeral() // removes "b", "c", and "g" lines
    ///     // just "a" has been printed now
    ///
    public func pushEphemeral() {
        depth += 1
        levels[depth] = 0
    }

    /// Pops a previous ephemeral console state. All text outputted to the console immidiately after the last call
    /// to `pushEphemeral()` will be cleared.
    ///
    /// This method can be called once for each call to `pushEphemeral()`.
    ///
    ///     console.print("a")
    ///     console.pushEphemeral()
    ///     console.print("b")
    ///     console.print("c")
    ///     console.pushEphemeral()
    ///     console.print("d")
    ///     console.print("e")
    ///     console.print("f")
    ///     console.popEphemeral() // removes "d", "e", and "f" lines
    ///     console.print("g")
    ///     console.popEphemeral() // removes "b", "c", and "g" lines
    ///     // just "a" has been printed now
    ///
    public func popEphemeral() {
        precondition(depth > 0, "popEphemeral() must be called (once) after pushEphemeral()")
        let lines = levels[depth] ?? 0
        guard lines > 0 else {
            levels[depth] = nil
            depth -= 1
            return
        }

        clear(lines: lines)

        // remember to reset depth after or else
        // the lines will get messed up
        levels[depth] = nil
        depth -= 1
    }

    /// This method allows the `Console` implementation to record how many lines have been printed so
    /// that `pushEphemeral()` and `popEphemeral()` knows how many lines to clear.
    ///
    /// This method should only be used by `Console` implementations.
    public func didOutputLines(count: Int) {
        guard self.depth > 0 else {
            // not in an ephemeral state
            return
        }

        if let existing = levels[self.depth] {
            self.levels[self.depth] = existing + count
        } else {
            self.levels[self.depth] = count
        }
    }

    /// Tracks how many successive calls to `pushEphemeral()` have been made.
    ///
    /// Calling `popEphemeral()` will decrement this number.
    private var depth: Int {
        get { return (self.userInfo["depth"] as? Int) ?? 0 }
        set { self.userInfo["depth"] = newValue }
    }

    /// Stores how many lines have been outputted at each depth.
    ///
    /// Calling `didOutputLines(count:)` will increase this number for the current depth.
    private var levels: [Int: Int] {
        get { return (userInfo["levels"] as? [Int: Int]) ?? [:] }
        set { self.userInfo["levels"] = newValue }
    }
}

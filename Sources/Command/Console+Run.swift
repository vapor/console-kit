import Console

extension Console {
    public func run(_ runnable: Runnable, arguments: [String]) throws {
        var input = try Input(raw: arguments)
        try run(runnable, with: &input)
    }

    private func run(_ group: Group, with input: inout Input) throws {
        if let name = input.arguments.pop() {
            guard let chosen = group.signature.runnables[name] else {
                throw ConsoleError(identifier: "unknownRunnable", reason: "Unknown argument `\(name)`.")
            }

            // executable should include all subcommands
            // to get to the desired command
            input.executable += " " + name
            try run(chosen, with: &input)
        } else {
            if input.options["help"]?.bool == true {
                try outputHelp(for: group, executable: input.executable)
            } else {
                let validated = try input.validate(using: group.signature)
                try group.run(using: self, with: validated)
            }
        }
    }

    private func run(_ command: Command, with input: inout Input) throws {
        if input.options["help"]?.bool == true {
            try outputHelp(for: command, executable: input.executable)
        } else {
            let validated = try input.validate(using: command.signature)
            try command.run(using: self, with: validated)
        }
    }

    private func run(_ runnable: Runnable, with input: inout Input) throws {
        switch runnable {
        case .command(let command):
            try run(command, with: &input)
        case .group(let group):
            try run(group, with: &input)
        }
    }

    private func outputHelp(for group: Group, executable: String) throws {
        try info("Usage: ", newLine: false)
        try print(executable, newLine: false)
        try warning(" <command> ", newLine: false)

        for opt in group.signature.options {
            try success("[--" + opt.name + "] ", newLine: false)
        }
        try print()

        try print()

        for help in group.signature.help {
            try print(help)
        }

        let padding = (group.signature.runnables.keys
            + group.signature.options.map { $0.name })
            .longestCount + 2

        try print()
        if group.signature.runnables.count > 0 {
            try success("Commands:")
            for (key, runnable) in group.signature.runnables {
                try outputHelpListItem(name: key, help: runnable.help, style: .warning, padding: padding)
            }
        }

        try print()
        if group.signature.options.count > 0 {
            try success("Options:")
            for opt in group.signature.options {
                try outputHelpListItem(name: opt.name, help: opt.help, style: .success, padding: padding)
            }
        }

        try print()
        try print()

        try print("Use `\(executable) ", newLine: false)
        try warning("command", newLine: false)
        try print(" --help` for more information on a command.")
    }

    private func outputHelp(for command: Command, executable: String) throws {
        try info("Usage: ", newLine: false)
        try print(executable + " ", newLine: false)
        for arg in command.signature.arguments {
            try warning("<" + arg.name + "> ", newLine: false)
        }
        for opt in command.signature.options {
            try success("[--" + opt.name + "] ", newLine: false)
        }
        try print()

        try print()

        for help in command.signature.help {
            try print(help)
        }

        let padding = (command.signature.arguments.map { $0.name }
            + command.signature.options.map { $0.name })
            .longestCount + 2

        try print()
        if command.signature.arguments.count > 0 {
            try info("Arguments:")
            for arg in command.signature.arguments {
                try outputHelpListItem(name: arg.name, help: arg.help, style: .warning, padding: padding)
            }
        }

        try print()
        if command.signature.options.count > 0 {
            try success("Options:")
            for opt in command.signature.options {
                try outputHelpListItem(name: opt.name, help: opt.help, style: .success, padding: padding)
            }
        }
    }

    private func outputHelpListItem(name: String, help: [String], style: ConsoleStyle, padding: Int) throws {
        try output(name.leftPad(to: padding - name.count), style: style, newLine: false)
        for (i, help) in help.enumerated() {
            if i == 0 {
                try print(help.leftPad(to: 1))
            } else {
                try print(help.leftPad(to: padding + 1))
            }
        }
    }
}

extension String {
    func leftPad(to padding: Int) -> String {
        return String(repeating: " ", count: padding) + self
    }
}

extension Array where Element == String {
    var longestCount: Int {
        var count = 0

        for item in self {
            if item.count > count {
                count = item.count
            }
        }

        return count
    }
}

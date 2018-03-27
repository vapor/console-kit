import Console

extension OutputConsole {
    /// Outputs help for a command.
    public func outputHelp(for runnable: CommandRunnable, executable: String) throws {
        info("Usage: ", newLine: false)
        print(executable + " ", newLine: false)

        switch runnable.type {
        case .command(let arguments):
            for arg in arguments {
                warning("<" + arg.name + "> ", newLine: false)
            }
        case .group:
            warning("<command> ", newLine: false)
        }

        for opt in runnable.options {
            if let short = opt.short {
                success("[--\(opt.name),-\(short)] ", newLine: false)
            } else {
                success("[--\(opt.name)] ", newLine: false)
            }
        }
        print()
        print()

        for help in runnable.help {
            print(help)
        }

        var names = runnable.options.map { $0.name }

        switch runnable.type {
        case .command(let arguments):
            names += arguments.map { $0.name }
        case .group(let commands):
            names += commands.keys
        }

        let padding = names.longestCount + 2

        print()
        if let command = runnable as? Command {
            if command.arguments.count > 0 {
                info("Arguments:")
                for arg in command.arguments {
                    outputHelpListItem(
                        name: arg.name,
                        help: arg.help,
                        style: .warning,
                        padding: padding
                    )
                }
            }
        }

        switch runnable.type {
        case .command: break
        case .group(let commands):
            if commands.count > 0 {
                success("Commands:")
                for (key, runnable) in commands {
                    outputHelpListItem(
                        name: key,
                        help: runnable.help,
                        style: .warning,
                        padding: padding
                    )
                }
            }
        }

        print()
        if runnable.options.count > 0 {
            success("Options:")
            for opt in runnable.options {
                outputHelpListItem(
                    name: opt.name,
                    help: opt.help,
                    style: .success,
                    padding: padding
                )
            }
        }

        switch runnable.type {
        case .command: break
        case .group:
            print()
            print("Use `\(executable) ", newLine: false)
            warning("<command>", newLine: false)
            print(" --help` for more information on a command.")
        }
    }

    private func outputHelpListItem(name: String, help: [String], style: ConsoleStyle, padding: Int) {
        output(name.leftPad(to: padding - name.count), style: style, newLine: false)
        for (i, help) in help.enumerated() {
            if i == 0 {
                print(help.leftPad(to: 1))
            } else {
                print(help.leftPad(to: padding + 1))
            }
        }
    }
}

extension String {
    fileprivate func leftPad(to padding: Int) -> String {
        return String(repeating: " ", count: padding) + self
    }
}

extension Array where Element == String {
    fileprivate var longestCount: Int {
        var count = 0

        for item in self {
            if item.count > count {
                count = item.count
            }
        }

        return count
    }
}

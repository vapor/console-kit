extension Console {
    /// Outputs help for a `CommandRunnable`, this is called automatically when `--help` is
    /// passed or when input validation fails.
    internal func outputHelp(for runnable: CommandRunnable, executable: String) {
        output("Usage: ".consoleText(.info) + executable.consoleText() + " ", newLine: false)

        switch runnable.type {
        case .command(let arguments):
            for arg in arguments {
                output(("<" + arg.name + "> ").consoleText(.warning), newLine: false)
            }
        case .group:
            output("<command> ".consoleText(.warning), newLine: false)
        }

        for opt in runnable.options {
            if let short = opt.short {
                output("[--\(opt.name),-\(short)] ".consoleText(.success), newLine: false)
            } else {
                output("[--\(opt.name)] ".consoleText(.success), newLine: false)
            }
        }
        print()

        if !runnable.help.isEmpty {
            print()

            for help in runnable.help {
                print(help)
            }
        }

        var names = runnable.options.map { $0.name }

        switch runnable.type {
        case .command(let arguments):
            names += arguments.map { $0.name }
        case .group(let commands):
            names += commands.commands.keys
        }

        let padding = names.longestCount + 2

        if let command = runnable as? Command {
            if command.arguments.count > 0 {
                print()
                output("Arguments:".consoleText(.info))
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
            if commands.commands.count > 0 {
                print()
                output("Commands:".consoleText(.success))
                for (key, runnable) in commands.commands {
                    var help: [String]
                    if key == commands.defaultCommand {
                        if runnable.help.count > 0 {
                            help = ["(default) " + runnable.help[0]]
                            if runnable.help.count > 1 {
                                help += runnable.help[1...]
                            }
                        } else {
                            help = ["(default) n/a"]
                        }
                    } else {
                        help = runnable.help
                    }
                    outputHelpListItem(
                        name: key,
                        help: help,
                        style: .warning,
                        padding: padding
                    )
                }
            }
        }

        if runnable.options.count > 0 {
            print()
            output("Options:".consoleText(.info))
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
            output("<command>".consoleText(.warning), newLine: false)
            output(" [--help,-h]".consoleText(.success) + "` for more information on a command.")
        }
    }

    private func outputHelpListItem(name: String, help: [String], style: ConsoleStyle, padding: Int) {
        output(name.leftPad(to: padding - name.count).consoleText(style), newLine: false)
        if help.isEmpty {
            print(" n/a")
        } else {
            for (i, help) in help.enumerated() {
                if i == 0 {
                    print(help.leftPad(to: 1))
                } else {
                    print(help.leftPad(to: padding + 1))
                }
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

import Polymorphic

public protocol Runnable {
    var id: String { get }
}

public protocol Command: Runnable {
    var console: Console { get }
    func run(arguments: [String]) throws

    var signature: [Argument] { get }
    var help: [String] { get }
}

public class Group: Runnable {
    public var id: String
    public var commands: [Runnable]
    public var help: [String]

    public init(id: String, commands: [Runnable], help: [String]) {
        self.id = id
        self.commands = commands
        self.help = help
    }
}

extension Command {
    public var signature: [Argument] {
        return []
    }
    public var help: [String] {
        return []
    }
}

public protocol Argument {
    var name: String { get }
    var help: [String] { get }
}

public struct Value: Argument {
    public var name: String
    public var help: [String]

    public init(name: String, help: [String] = []) {
        self.name = name
        self.help = help
    }
}

public struct Option: Argument {
    public var name: String
    public var help: [String]

    public init(name: String, help: [String] = []) {
        self.name = name
        self.help = help
    }
}

extension Sequence where Iterator.Element == Argument {
    public var values: [Value] {
        return flatMap { $0 as? Value }
    }

    public var options: [Option] {
        return flatMap { $0 as? Option }
    }
}

extension Command {
    public func value(_ name: String, from arguments: [String]) throws -> Polymorphic {
        for (i, value) in signature.values.enumerated() {
            if value.name == name {
                return arguments[i]
            }
        }

        throw ConsoleError.argumentNotFound
    }
}

extension Command {
    public func printUsage(executable: String) {
        console.info("Usage: ", newLine: false)
        console.print("\(executable) \(id) ", newLine: false)

        var signatureLine: [String] = []

        for value in signature.values {
            signatureLine.append("<\(value.name)>")
        }

        for option in signature.options {
            signatureLine.append("[--\(option.name)]")
        }

        console.print(signatureLine.joined(separator: " "))
    }

    public func printSignatureHelp() {
        var namePadding = 0
        for argument in signature {
            let count = argument.name.characters.count

            if count > namePadding {
                namePadding = count
            }
        }

        for argument in signature {
            let padding = ""
            console.print(padding, newLine: false)

            for _ in 0 ..< (namePadding - argument.name.characters.count) {
                console.print(" ", newLine: false)
            }

            console.print(argument.name, newLine: false)
            console.print(": ", newLine: false)

            for (i, help) in argument.help.enumerated() {
                if i != 0 {
                    console.print(padding, newLine: false)
                    for _ in 0 ..< namePadding {
                        console.print(" ", newLine: false)
                    }
                    console.print("  ", newLine: false)
                }

                console.print(help)
            }
        }

    }
}

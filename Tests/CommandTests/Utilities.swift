import Console
import Command

final class TestConsole: Console {
    var output: String
    var input: String
    var error: String
    var lastAction: ConsoleAction?
    var extend: [String : Any] = [:]

    init() {
        self.output = ""
        self.input = ""
        self.error = ""
        self.lastAction = nil
    }

    func action(_ action: ConsoleAction) throws -> String? {
        switch action {
        case .input(_):
            let t = input
            input = ""
            return t
        case .output(let output, _, let newLine):
            self.output += output + (newLine ? "\n" : "")
        case .error(let error, let newLine):
            self.error += error + (newLine ? "\n" : "")
        default:
            break
        }
        lastAction = action
        return nil
    }

    var size: (width: Int, height: Int) {
        return (640, 320)
    }
}

final class TestGroup: Group {
    let signature: GroupSignature

    init() {
        signature = .init(runnables: [
            "test": .command(TestCommand())
        ], options: [
            .init(name: "version")
        ], help: ["This is a test grouping!"])
    }

    func run(using console: Console, with input: GroupInput) throws {
        if input.options["version"]?.bool == true {
            try console.print("v2.0")
        } else {
            throw "unknown"
        }
    }
}

final class TestCommand: Command {
    let signature: CommandSignature

    init() {
        signature = .init(arguments: [
            .init(name: "foo", help: ["A foo is required", "An error will occur if none exists"])
        ], options: [
            .init(name: "bar", help: ["Add a bar if you so desire", "Try passing it"])
        ], help: ["This is a test command"])
    }

    func run(using console: Console, with input: CommandInput) throws {
        let foo = try input.argument("foo")
        let bar = try input.assertOption("bar")
        try console.info("Foo: \(foo) Bar: \(bar)")
    }
}

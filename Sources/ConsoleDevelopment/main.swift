import Command
import Console
import Logging

struct CowsayCommand: Command {
    var arguments: [CommandArgument] {
        return [.argument(name: "message")]
    }

    var options: [CommandOption] {
        return [
            .value(name: "eyes", short: "e", help: ["Change cow's eyes", "'oo' by default"]),
            .value(name: "tongue", short: "t"),
        ]
    }

    var help: [String] {
        return ["Generates ASCII picture of a cow with a message."]
    }

    func run(using context: CommandContext) throws -> Future<Void> {
        let message = try context.argument("message")
        let eyes = context.options["eyes"] ?? "oo"
        let tongue = context.options["tongue"] ?? " "
        let padding = String(repeating: "-", count: message.count)
        let text: String = """
          \(padding)
        < \(message) >
          \(padding)
                  \\   ^__^
                   \\  (\(eyes)\\_______
                      (__)\\       )\\/\\
                        \(tongue)  ||----w |
                           ||     ||
        """
        context.console.print(text)
        return .done(on: context.container)
    }
}

var config = CommandConfig()
config.use(CowsayCommand(), as: "cowsay")


let console = Terminal()
let worker = EmbeddedEventLoop()

var env = Environment.testing
let container = BasicContainer(config: .init(), environment: env, services: .init(), on: worker)

let group = try config.resolve(for: container).group()
try console.run(group, input: &env.commandInput, on: container).wait()

exit(0)

//let shared = ConsoleLogger(console: console)
//
//Thread.async {
//    while true {
//        shared.info("This is a message from 1")
//    }
//}
//Thread.async {
//    while true {
//        shared.info("This is a message from 2")
//    }
//}
//Thread.async {
//    while true {
//        shared.info("This is a message from 3")
//    }
//}
//Thread.async {
//    while true {
//        shared.info("This is a message from 4")
//    }
//}
//
//
//console.blockingWait(seconds: 5)

console.confirmOverride = true

if !console.confirm("Delete everything?") {
    console.warning("I won't do it....")
}

do {
    var text: ConsoleText = ""
    text += "Bold".consoleText(isBold: true)
    text += " not bold "
    text += "green".consoleText(color: .green, background: .blue)
    console.output(text)
}

do {
    let text = "Bold".consoleText(isBold: true)
        + " not bold "
        + "green".consoleText(color: .green, background: .blue)
    console.output(text)
}

let color = console.choose("Favorite color?", from: ["Pink", "Blue"])
console.output("You chose: " + color.consoleText())

console.print("a")
console.pushEphemeral()
console.print("b")
console.print("c")
console.pushEphemeral()
console.print("d")
console.print("e")
console.print("f")
console.blockingWait(seconds: 1)
console.popEphemeral() // removes "d", "e", and "f" lines
console.print("g")
console.blockingWait(seconds: 1)
console.popEphemeral() // removes "b", "c", and "g" lines
// just "a" has been printed now

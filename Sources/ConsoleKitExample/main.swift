import ConsoleKit

let console: Console = Terminal()

let funDemoText: ConsoleText = ""
    + "D".consoleText(color: .red)
    + "e".consoleText(color: .yellow)
    + "m".consoleText(color: .green)
    + "o".consoleText(color: .blue)
    + "!".consoleText(color: .magenta)

console.output("Welcome to the ConsoleKit " + funDemoText)
let name = console.ask("What is your name?".consoleText(.info))
console.print("Hello, \(name) 👋")

console.info("Here's an example of loading")

let loadingBar = console.loadingBar(title: "Loading")
loadingBar.start()

console.wait(seconds: 2)
loadingBar.succeed()

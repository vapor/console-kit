import Console

let console: ConsoleProtocol = Terminal(arguments: CommandLine.arguments)

console.output("Welcome", style: .custom(.red), newLine: false)
console.output(" to", style: .custom(.yellow), newLine: false)
console.output(" the", style: .custom(.green), newLine: false)
console.output(" Console", style: .custom(.cyan), newLine: false)
console.output(" Example!", style: .custom(.magenta))

console.print()


// TEST DEMO

let name = console.ask("What is your name?")

console.print("Hello, \(name).")

console.wait(seconds: 1.5)
console.print()

console.print("I can show progress bars...")
console.wait(seconds: 1.5)
console.clear(.line)

let progressBar = console.progressBar(title: "backups.dat")

let cycles = 30
for i in 0 ... cycles {
    if i != 0 {
        console.wait(seconds: 0.05)
    }
    progressBar.progress = Double(i) / Double(cycles)
}

progressBar.finish()

console.wait(seconds: 0.5)
console.print()

console.print("I can show loading bars...")
console.wait(seconds: 1.5)
console.clear(.line)


let loadingBar = console.loadingBar(title: "Connecting...")

loadingBar.start()
console.wait(seconds: 2.5)
loadingBar.finish()


console.wait(seconds: 0.5)
console.print()

console.print("I can show...")
console.wait(seconds: 1.5)
console.clear(.line)

console.print("Plain messages")
console.wait(seconds: 0.5)

console.info("Informational messages")
console.wait(seconds: 0.5)

console.success("Success messages")
console.wait(seconds: 0.5)

console.warning("Warning messages")
console.wait(seconds: 0.5)

console.error("Error messages")
console.wait(seconds: 0.5)

console.wait(seconds: 0.5)
console.print()

console.print("Thanks for watching, \(name)!")
console.wait(seconds: 1.5)
console.clear(.line)


console.info("Goodbye! 👋")
console.print()

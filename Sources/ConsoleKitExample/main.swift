import ConsoleKit
import Dispatch

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

console.info("Here's an example of progress")

let workGroup = DispatchGroup()
let updateQueue = DispatchQueue(label: "codes.vapor.consolekitexample.updateBar")
let progressBar = console.progressBar(title: "Long-running background stuff", targetQueue: updateQueue)

let workQueue = DispatchQueue(label: "codes.vapor.consolekitexample.doWork")

progressBar.start()

workGroup.enter()
workQueue.async {
    let durationSeconds: Double = 3.0
    let count = 50
    for i in 0 ..< count {
        console.wait(seconds: durationSeconds / Double(count))
        updateQueue.async {
            progressBar.activity.currentProgress = Double(i) / Double(count)
        }
    }
    workGroup.leave()
}

workGroup.wait()
progressBar.succeed()

console.success("Example completed successfully")

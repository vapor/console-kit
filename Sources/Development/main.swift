import Console

let console = Terminal()

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

import Console

let console = Terminal()
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
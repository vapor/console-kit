#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Console

let console: Console = Terminal()

console.output("Welcome", style: .custom(.red), newLine: false)
console.output(" to", style: .custom(.yellow), newLine: false)
console.output(" the", style: .custom(.green), newLine: false)
console.output(" Console", style: .custom(.cyan), newLine: false)
console.output(" Example!", style: .custom(.magenta))

console.print()

let name = console.ask("What is your name?")

console.print("Hello, \(name).")
console.print()

if console.confirm("Would you like to see a download simulated?") {
    let shouldFail = console.confirm("Would you like the download to fail?")

    console.print()
    console.print("Simulating a download...")
    let progressBar = console.progressBar(title: shouldFail ? "passwords.txt" : "garbage.dat")

    let cycles = 30
    for i in 0 ... cycles {
        if i != 0 {
            usleep(50 * 1000)
        }
        progressBar.progress = Double(i) / Double(cycles)
    }

    if shouldFail {
        progressBar.fail("Failed (You asked for it)")
    } else {
        progressBar.finish("Done (As you wished)")
    }

    console.print()
}

if console.confirm("Would you like to see loading simulated?") {
    let shouldFail = console.confirm("Would you like the load to fail?")

    console.print()
    console.print("Simulating loading...")
    let loadingBar = console.loadingBar(title: shouldFail ? "Important thing" : "Unimportant thing")

    loadingBar.start()

    usleep(1000 * 1000)

    if shouldFail {
        loadingBar.fail()
    } else {
        loadingBar.finish()
    }
    
    console.print()
}

if console.confirm("Would you like to see the various console styles?") {
    console.print()
    console.print("print")
    console.info("info")
    console.success("success")
    console.warning("warning")
    console.error("error")
    console.print()
    console.output(".custom(.black)", style: .custom(.black))
    console.output(".custom(.red)", style: .custom(.red))
    console.output(".custom(.green)", style: .custom(.green))
    console.output(".custom(.yellow)", style: .custom(.yellow))
    console.output(".custom(.blue)", style: .custom(.blue))
    console.output(".custom(.magenta)", style: .custom(.magenta))
    console.output(".custom(.cyan)", style: .custom(.cyan))
    console.output(".custom(.white)", style: .custom(.white))
    console.print()
}

console.info("Goodbye! 👋")

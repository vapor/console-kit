import ConsoleKit
import Testing

@Suite("Console Tests")
struct ConsoleTests {
    @Test("Loading")
    func loading() async throws {
        let console = Terminal()
        let foo = console.loadingBar(title: "Loading")

        try await foo.withActivityIndicator {
            try await Task.sleep(for: .seconds(2.5))
            return true
        }
    }

    @Test("Progress")
    func progress() async throws {
        let console = Terminal()
        let foo = console.progressBar(title: "Progress")
        
        try await foo.withActivityIndicator {
            while true {
                if foo.activity.currentProgress >= 1.0 {
                    return true
                } else {
                    foo.activity.currentProgress += 0.1
                    try await Task.sleep(for: .seconds(0.1))
                }
            }
        }
    }

    @Test("Custom Indicator")
    func customIndicator() async throws {
        let console = Terminal()
        
        let indicator = console.customActivity(frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"])
        
        try await indicator.withActivityIndicator {
            try await Task.sleep(for: .seconds(3))
            return true
        }
    }
    
    @Test("Ephemeral")
    func ephemeral() async throws {
        // for some reason, piping through test output doesn't work correctly
        // but this code works great if running directly in an executable

        // added here anyway to verify that the code snippet in doc blocks actually compiles
        let console = Terminal()
        console.print("a")
        console.pushEphemeral()
        console.print("b")
        console.print("c")
        console.pushEphemeral()
        console.print("d")
        console.print("e")
        console.print("f")
        try await Task.sleep(for: .seconds(1))
        console.popEphemeral() // removes "d", "e", and "f" lines
        console.print("g")
        try await Task.sleep(for: .seconds(1))
        console.popEphemeral() // removes "b", "c", and "g" lines
        // just "a" has been printed now
    }

    @Test("Ask")
    func ask() throws {
        let console = TestConsole()

        let name = "Test Name"
        let question = "What is your name?"

        console.testInputQueue.append(name)

        let response = console.ask(question.consoleText(.plain))

        #expect(response == name)
        #expect(console.testOutputQueue.reversed().joined() == question + "\n> ")
    }

    @Test("Confirm")
    func confirm() throws {
        let console = TestConsole()

        let name = "y"
        let question = "Do you want to continue?"

        console.testInputQueue.append(name)

        let response = console.confirm(question.consoleText(.info))

        #expect(response == true)
        #expect(console.testOutputQueue.reversed().joined() == question + "\ny/n> ")
    }
}

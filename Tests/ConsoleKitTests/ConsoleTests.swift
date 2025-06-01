import ConsoleKit
import Testing

@Suite("Console Tests")
struct ConsoleTests {
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
        console.popEphemeral()  // removes "d", "e", and "f" lines
        console.print("g")
        try await Task.sleep(for: .seconds(1))
        console.popEphemeral()  // removes "b", "c", and "g" lines
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

    @Test("Center String")
    func centerString() throws {
        let console = TestConsole()

        let centeredText = console.center("Hello, World!\nHello, World!")

        #expect(centeredText == "         Hello, World!\n         Hello, World!")
    }

    @Test("Center Array of Strings")
    func centerArrayOfStrings() throws {
        let console = TestConsole()

        let text = ["Hello, World!", "Hello, World!"]
        let centeredText = console.center(text)

        #expect(centeredText == ["         Hello, World!", "         Hello, World!"])
    }

    @Test("Center ConsoleText Array")
    func centerConsoleTextArray() throws {
        let console = TestConsole()

        let text: [ConsoleText] = .init(repeating: "Hello, World!".consoleText(.info), count: 10)
        let centeredText = console.center(text)

        for i in 0..<text.count {
            #expect(centeredText[i].description == "         Hello, World!")
        }
    }

    @Test("Center ConsoleText")
    func centerConsoleText() throws {
        let console = TestConsole()

        let centeredText = console.center("Hello, World!".consoleText(.info))

        #expect(centeredText.description == "         Hello, World!")
    }
}

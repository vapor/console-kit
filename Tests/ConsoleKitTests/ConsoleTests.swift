import ConsoleKit
import Testing

@Suite("Console Tests")
struct ConsoleTests {
    @Test("Output String")
    func outputString() throws {
        let console = TestConsole()

        let text = "Hello, World!"
        console.output(text, style: .info)

        #expect(console.testOutputQueue.reversed().joined() == text + "\n")
    }

    @Test("Print Info")
    func printInfo() throws {
        let console = TestConsole()

        let text = "Vapor is the best."
        console.info(text)

        #expect(console.testOutputQueue.reversed().joined() == text + "\n")
    }

    @Test("Print Success")
    func printSuccess() throws {
        let console = TestConsole()

        let text = "Operation completed successfully."
        console.success(text)

        #expect(console.testOutputQueue.reversed().joined() == text + "\n")
    }

    @Test("Print Warning")
    func printWarning() throws {
        let console = TestConsole()

        let text = "This is a warning message."
        console.warning(text)

        #expect(console.testOutputQueue.reversed().joined() == text + "\n")
    }

    @Test("Print Error")
    func printError() throws {
        let console = TestConsole()

        let text = "An error occurred."
        console.error(text)

        #expect(console.testOutputQueue.reversed().joined() == text + "\n")
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

        let question = "Do you want to continue?"

        console.testInputQueue.append("y")

        let response = console.confirm(question.consoleText(.info))

        #expect(response == true)
        #expect(console.testOutputQueue.reversed().joined() == question + "\ny/n> ")
    }

    @Test("Confirm with Invalid Input")
    func confirmWithInvalidInput() throws {
        let console = TestConsole()

        let question = "Do you want to continue?"

        console.testInputQueue.append("y")
        console.testInputQueue.append("invalid")

        let response = console.confirm(question.consoleText(.info))

        #expect(response == true)
        #expect(console.testOutputQueue.reversed().joined() == question + "\ny/n> " + question + "\n[y]es or [n]o> ")
    }

    @Test("Confirm with Override")
    func confirmWithOverride() throws {
        let console = TestConsole()

        let question = "Do you want to continue?"

        console.confirmOverride = true

        let response = console.confirm(question.consoleText(.info))

        #expect(response == true)
        #expect(console.testOutputQueue.reversed().joined() == question + "\ny/n> yes\n")
    }

    @Test("Choose")
    func choose() throws {
        let console = TestConsole()

        let options = ["Option 1", "Option 2", "Option 3"]
        let question = "Please choose an option:"

        console.testInputQueue.append("2")

        let response = console.choose(question.consoleText(.info), from: options)

        #expect(response == "Option 2")
        #expect(console.testOutputQueue.reversed().joined() == question + "\n1: Option 1\n2: Option 2\n3: Option 3\n> ")
    }

    @Test("Choose with Invalid Input")
    func chooseWithInvalidInput() throws {
        let console = TestConsole()

        let options = ["Option 1", "Option 2", "Option 3"]
        let question = "Please choose an option:"

        console.testInputQueue.append("2")
        console.testInputQueue.append("4")  // Invalid input

        let response = console.choose(question.consoleText(.info), from: options)

        #expect(response == "Option 2")
        #expect(console.testOutputQueue.reversed().joined() == question + "\n1: Option 1\n2: Option 2\n3: Option 3\n> > ")
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

    @Test("Center Empty Array of Strings")
    func centerEmptyArrayOfStrings() throws {
        let console = TestConsole()

        let text: [String] = []
        let centeredText = console.center(text)

        #expect(centeredText.isEmpty)
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

    @Test("Center Empty ConsoleText Array")
    func centerEmptyConsoleTextArray() throws {
        let console = TestConsole()

        let text: [ConsoleText] = []
        let centeredText = console.center(text)

        #expect(centeredText.isEmpty)
    }

    @Test("ConsoleText Operations")
    func consoleTextOperations() throws {
        let consoleText: ConsoleText = ["foo", "bar", "baz", "qux"]

        #expect(consoleText.startIndex == 0)
        #expect(consoleText.endIndex == 4)
        #expect(consoleText[0].string == "foo")
        #expect(consoleText.index(after: 0) == 1)

        var emptyConsoleText: ConsoleText = ""
        #expect(emptyConsoleText.fragments.isEmpty)
        emptyConsoleText += "foo"
        #expect(emptyConsoleText.fragments.count == 1)

        let interpolationStyleConsoleText: ConsoleText = "Hello, \("World", style: .info)!"
        #expect(interpolationStyleConsoleText.description == "Hello, World!")

        let interpolationColorConsoleText: ConsoleText = "Hello, \("World", color: .red)!"
        #expect(interpolationColorConsoleText.description == "Hello, World!")

        let consoleTextFragment = ConsoleTextFragment(string: "Hi Mom", style: .info)
        #expect(consoleTextFragment.description == "Hi Mom")
    }
}

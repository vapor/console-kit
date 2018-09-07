import Async
import Command
import Console
import Service
import XCTest

class CommandTests: XCTestCase {
    func testHelp() throws {
        let console = TestConsole()
        let group = TestGroup()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
        var input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try console.run(group, input: &input, on: container).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Usage: vapor sub test <foo> [<baz>] [--bar,-b]\u{20}

        This is a test command

        Arguments:
          foo A foo is required
              An error will occur if none exists
          baz A baz is optional
              No error will occur if it is not passed in

        Options:
          bar Add a bar if you so desire
              Try passing it

        """)
    }

    func testFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar", "baz"])
        try console.run(group, input: &input, on: container).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "-b", "baz"])
        try console.run(group, input: &input, on: container).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testDeprecatedFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar=baz"])
        try console.run(group, input: &input, on: container).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testOptionlArg()throws {
        let console = TestConsole()
        let group = TestGroup()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "bazvalue", "--bar=baz"])
        try console.run(group, input: &input, on: container).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Baz: bazvalue Foo: foovalue Bar: baz

        """)
    }
    
    static var allTests = [
        ("testHelp", testHelp),
        ("testFlag", testFlag),
        ("testShortFlag", testShortFlag),
        ("testDeprecatedFlag", testDeprecatedFlag),
        ("testOptionlArg", testOptionlArg)
    ]
}

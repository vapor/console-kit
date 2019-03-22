import ConsoleKit
import XCTest

class CommandTests: XCTestCase {
    func testHelp() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try console.run(group, input: &input).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Usage: vapor sub test <foo> [--bar,-b]\u{20}

        This is a test command

        Arguments:
          foo A foo is required
              An error will occur if none exists

        Options:
          bar Add a bar if you so desire
              Try passing it

        """)
    }

    func testFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar", "baz"])
        try console.run(group, input: &input).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "-b", "baz"])
        try console.run(group, input: &input).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlagNeedsToMatchExactly() throws {
        var input = CommandInput(arguments: ["vapor", "sub", "test", "-x", "exact", "-y_not_exact", "not_exact"])
        XCTAssertEqual(try input.parse(option: .value(name: "xShort", short: "x")), "exact")
        XCTAssertNil(try input.parse(option: .value(name: "yShort", short: "y")))
    }

    func testDeprecatedFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar=baz"])
        try console.run(group, input: &input).wait()
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    static var allTests = [
        ("testHelp", testHelp),
        ("testFlag", testFlag),
        ("testShortFlag", testShortFlag),
        ("testShortFlagNeedsToMatchExactly", testShortFlagNeedsToMatchExactly),
        ("testDeprecatedFlag", testDeprecatedFlag),
    ]
}

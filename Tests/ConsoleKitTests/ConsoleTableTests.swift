import ConsoleKit
import Testing

@Suite("Console Table Tests")
struct ConsoleTableTests {
    @Test("Basic Table Rendering")
    func basicTable() throws {
        let console = TestConsole()

        console.printTable([
            ["Name", "Age"],
            ["Alice", "30"],
            ["Bob", "25"],
        ])

        let expected = """
        ┌───────┬─────┐
        │ Name  │ Age │
        ├───────┼─────┤
        │ Alice │ 30  │
        │ Bob   │ 25  │
        └───────┴─────┘

        """
        #expect(console.testOutputQueue.reversed().joined() == expected)
    }

    @Test("Table With Ragged Rows")
    func raggedRows() throws {
        let console = TestConsole()

        console.printTable([
            ["A", "B", "C"],
            ["1"],
            ["2", "3"],
        ])

        let expected = """
        ┌───┬───┬───┐
        │ A │ B │ C │
        ├───┼───┼───┤
        │ 1 │   │   │
        │ 2 │ 3 │   │
        └───┴───┴───┘

        """
        #expect(console.testOutputQueue.reversed().joined() == expected)
    }

    @Test("Empty Table Renders Nothing")
    func emptyTable() throws {
        let console = TestConsole()

        console.printTable([])

        #expect(console.testOutputQueue.reversed().joined() == "")
    }

    @Test("Header Separator Only After Header")
    func headerSeparator() throws {
        let console = TestConsole()

        console.printTable([
            ["Key", "Value"],
            ["a", "1"],
        ])

        let lines = console.testOutputQueue.reversed().joined().split(separator: "\n")
        #expect(lines.count == 5)
        #expect(lines[2].hasPrefix("├") && lines[2].hasSuffix("┤"))
    }

    @Test("Single Column Table")
    func singleColumn() throws {
        let console = TestConsole()

        console.printTable([
            ["Item"],
            ["x"],
        ])

        let expected = """
        ┌──────┐
        │ Item │
        ├──────┤
        │ x    │
        └──────┘

        """
        #expect(console.testOutputQueue.reversed().joined() == expected)
    }
}

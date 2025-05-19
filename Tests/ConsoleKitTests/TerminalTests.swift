import Testing
@testable import ConsoleKit

@Suite("Terminal Tests")
struct TerminalTests {
    @Test("Stylize Foreground")
    func stylizeForeground() throws {
        #expect("TEST".terminalStylize(.init(color: .black)) == "\u{001b}[0;30mTEST\u{001b}[0m")
    }
    
    @Test("Stylize Background")
    func stylizeBackground() throws {
        #expect("TEST".terminalStylize(.init(color: .white, background: .red)) == "\u{001b}[0;37;41mTEST\u{001b}[0m")
    }
    
    @Test("Stylize Bold")
    func stylizeBold() throws {
        #expect("TEST".terminalStylize(.init(color: .white, isBold: true)) == "\u{001b}[0;1;37mTEST\u{001b}[0m")
    }

    @Test("Stylize Only Bold")
    func stylizeOnlyBold() throws {
        #expect("TEST".terminalStylize(.init(color: nil, isBold: true)) == "\u{001b}[0;1mTEST\u{001b}[0m")
    }

    @Test("Stylize All Attributes")
    func stylizeAllAttrs() throws {
        #expect(
            "TEST".terminalStylize(.init(color: .brightWhite, background: .brightGreen, isBold: true)) ==
            "\u{001b}[0;1;97;102mTEST\u{001b}[0m"
        )
    }

    @Test("Stylize Plain")
    func stylizePlain() throws {
        #expect("TEST".terminalStylize(.plain) == "TEST")
    }

    @Test("Stylize Palette Color")
    func stylizePaletteColor() throws {
        #expect("TEST".terminalStylize(.init(color: .palette(100))) == "\u{001b}[0;38;5;100mTEST\u{001b}[0m")
        #expect("TEST".terminalStylize(.init(color: .white, background: .palette(100))) == "\u{001b}[0;37;48;5;100mTEST\u{001b}[0m")
    }

    @Test("Stylize RGB Color")
    func stylizeRGBColor() throws {
        #expect(
            "TEST".terminalStylize(.init(color: .custom(r: 100, g: 100, b: 100))) ==
            "\u{001b}[0;38;2;100;100;100mTEST\u{001b}[0m"
        )
        #expect(
            "TEST".terminalStylize(.init(color: .white, background: .custom(r: 100, g: 100, b: 100))) ==
            "\u{001b}[0;37;48;2;100;100;100mTEST\u{001b}[0m"
        )
    }
}


import XCTest

@testable import ConsoleKitTests

// MARK: ConsoleKitTests

extension ConsoleKitTests.CommandTests {
	static let __allCommandTestsTests = [
		("testHelp", testHelp),
		("testFlag", testFlag),
		("testShortFlag", testShortFlag),
		("testDeprecatedFlag", testDeprecatedFlag),
	]
}

extension ConsoleKitTests.ConsoleTests {
	static let __allConsoleTestsTests = [
		("testLoading", testLoading),
		("testProgress", testProgress),
		("testCustomIndicator", testCustomIndicator),
		("testEphemeral", testEphemeral),
		("testAsk", testAsk),
		("testConfirm", testConfirm),
	]
}

extension ConsoleKitTests.TerminalTests {
	static let __allTerminalTestsTests = [
		("testStylizeForeground", testStylizeForeground),
		("testStylizeBackground", testStylizeBackground),
		("testStylizeBold", testStylizeBold),
		("testStylizeOnlyBold", testStylizeOnlyBold),
		("testStylizeAllAttrs", testStylizeAllAttrs),
		("testStylizePlain", testStylizePlain),
		("testStylizePaletteColor", testStylizePaletteColor),
		("testStylizeRGBColor", testStylizeRGBColor),
	]
}

// MARK: Test Runner

#if !os(macOS)
public func __buildTestEntries() -> [XCTestCaseEntry] {
	return [
		// ConsoleKitTests
		testCase(CommandTests.__allCommandTestsTests),
		testCase(ConsoleTests.__allConsoleTestsTests),
		testCase(TerminalTests.__allTerminalTestsTests),
	]
}

let tests = __buildTestEntries()
XCTMain(tests)
#endif


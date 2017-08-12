#if os(Linux)

import XCTest
@testable import ConsoleTests
@testable import CommandTests

XCTMain([
    testCase(ConsoleTests.allTests),
    testCase(CommandTests.allTests)
])

#endif
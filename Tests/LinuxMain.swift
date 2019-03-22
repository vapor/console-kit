import XCTest

import CommandTests
import ConsoleTests

var tests = [XCTestCaseEntry]()
tests += CommandTests.__allTests()
tests += ConsoleTests.__allTests()

XCTMain(tests)
